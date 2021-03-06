class Event < ActiveRecord::Base
  belongs_to :segment
  has_many :activities, through: :connections
  has_many :points, dependent: :destroy
  has_many :efforts, through: :activities
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_many :featured_segments, class_name: "Feature",
                              foreign_key: "event_id",
                              dependent: :destroy
  has_many :features
  has_many :featuring, through: :featured_segments, source: :segment
  has_many :connections, dependent: :destroy
  has_many :contains, through: :connections, source: :activity
  has_many :races, dependent: :destroy
  belongs_to :series
  has_many :results
  has_many :segments, through: :featured_segments, source: :segment

  def get_gmap
    # polyline for shortest route of all competitors
    route = polyline2hash(self.activities.order(:distance).first.polyline)
    
    segments = [] # array of segment-polyline/segment-name/category dicts
    self.features.each do |f|
      if f.category == 'sprint'
        color = '#00FF00'
      else
        color = '#FF0000'
      end
      segments << {'route': polyline2hash(f.segment.polyline),
                    'name': f.segment.name,
                    'color': color}
    end
    winners = [] # array of end-segment-locs/winner-icons
    self.points.where(place: 1).each do |pt|
      winners << {'endpoint': pt.feature.segment.endpoint,
                  'user': User.find_by(id: pt.user_id)}
    end
    
    out =  {'route': route,
            'segments': segments,
            'winners': winners}
    return out
  end

  def finishers
    out = {}
    efforts = self.efforts.where(segment_id: self.segment_id)
    efforts.each do |effort|
      finish_time = (effort.start_date.to_i - self.start_date.to_i) + effort.elapsed_time
      out[effort.user_id] = {finish_time: finish_time,
                          effort: effort.id
      }
    end
    placed = 1
    out = out.sort_by{|k,v| v[:finish_time]}
    out.each do |k,v|
      v[:place] = placed
      placed += 1
    end
    return out
  end

  def polyline2hash(polyline)
    array = Polylines::Decoder.decode_polyline(polyline)
    track = []
    array.each do |pt|
      track << {lat: pt[0], lng: pt[1]}
    end
    return track
  end

  def make_connection activity
    Connection.create(activity_id: activity.id,
                      event_id: self.id)
  end
  
  def drop_connection activity
    self.connections.where(activity_id: activity.id).delete_all
  end

  def self.make_day d, name = nil, owner = nil, segments = nil, users = nil, end_segment = nil

    name = d.strftime('%a, %d %b %Y').to_s if name == nil
    event = Event.create(start_date: d,
                        name: name)
    if owner == nil
      owner = User.where(developer: true).first 
    end
    event.update(user_id: owner.id) if owner != nil
    event.update(segment_id: end_segment.id) if end_segment != nil
    if segments
      segments.each do |segment|
        
        Feature.create(segment_id: segment.id,
                        event_id: event.id,
                        category: 'sprint',
                        val: 6)
      end
    end
    if users and segments
      segment_ids = event.featuring.pluck(:segment_id)
      users.each do |user|
        user.activities.where(start_date: [event.start_date.beginning_of_day..event.start_date.end_of_day]).each do |activity|

          segment_set = segment_ids.to_set
          activity_set = activity.efforts.pluck(:segment_id).to_set

          if segment_set.subset? activity_set
            event.make_connection activity
          end
        end
      end
    end
    return event
  end

  def qualified_user user
    event_segments = Set[self.features.pluck(:segment_id)]
    user_segments = Set[user.efforts.where(start_date: [event.start_date.beginning_of_day..event.start_date.end_of_day]).pluck(:segment_id)]
    event_segments.subset?(user_segments) ? (return true): (return false)
  end


  def winner
    User.find_by(id: self.results.order(total: :desc).first.user_id)
  end

  def user_result user
    pts = self.points.where(user: user)
    bling = self.get_bling user
    if self.results.size > 0
      place = self.results.where(user: user).first.place
    else 
      place = 0
    end
      
    return {user: user,
            event: self,
            athletes: self.connections.count,
            place: place,
            sprint: pts.where(category: 'sprint').sum(:val),
            kom: pts.where(category: 'kom').sum(:val),
            total: pts.sum(:val),
            bling: bling
    }
  end

  def get_bling user
    bling = {}
    bling['sprint'] = self.points.where(user: user, category: 'sprint', place: 1).count
    bling['kom'] = self.points.where(user: user, category: 'kom', place: 1).count
    return bling
  end

  def make_results
    Result.where(event_id: self.id).delete_all
    results = []
    User.where(id: self.activities.pluck(:user_id).uniq).each do |user|
      puts self.user_result(user)
      results << self.user_result(user)
    end
    place = 1
    results = results.sort_by{|r| -r[:total]}
    results.each do |r|
      Result.create(event_id: r[:event].id,
                    user_id: r[:user].id,
                    kom: r[:kom],
                    sprint: r[:sprint],
                    total: r[:total],
                    place: place,
                    start_date: self.start_date
                    )
      place += 1
    end
    return nil
  end

  def results_table
    out = {}
    self.points.pluck(:user_id).uniq.each do |user_id|
      sprint = self.points.where(category: 'sprint').where(user_id: user_id).sum(:val)
      kom = self.points.where(category: 'kom', user_id: user_id).sum(:val)
      total = sprint + kom
      out[User.find_by(id: user_id).full_name] = {
        'sprint': sprint,
        'kom': kom,
        'total': total
      }
    end
    return out.sort_by {|athlete, scores| -scores[:total]}
  end

  def register user
    self.participations.create(user: user)
  end

  def unregister user
    self.participations.find_by(user_id: user.id).destroy
  end

  def array_subset(s, a)
    a.each do |i|
      if s.subset? i
        return true
      end
    end
    return false
  end

  def common_segments activities
    segment_array = []
      
    activities.each do |activity|
      segment_array << activity.efforts.pluck(:segment_id)
    end
    flat_array = segment_array.flatten
    segment_array.each {|sa| flat_array = flat_array & sa }
    return Segment.where(id: flat_array)
  end

  def add_activity activity
    Connection.create(event_id: self.id, activity_id: activity.id)
  end
  
  def remove_activity activity
    connections.where(activity_id: activity.id).destroy_all
  end
  
  def get_table

    out = []
    activities = self.contains
    activity_ids = activities.pluck(:id)
    if activities.count > 0
      self.start_date = activities.pluck(:start_date).min
    end

    official_start = self.start_date
    segments = self.featuring.pluck(:id)
    if activities.size > 0

      Point.where(event: self).delete_all
      self.featured_segments.each do |feature|
        winning_efforts = feature.segment.efforts.where(activity_id: activity_ids).order(:stop_date).limit(3)
         
        pts = feature.val || 3
        place = 1
        winning_efforts.each do |e|
          Point.create(event: self,
                    user_id: e.user_id,
                    effort: e,
                    category: feature.category,
                    feature_id: feature.id,
                    val: pts,
                    place: place)
          pts -= 1
          place += 1
        end
      end
      
      ordered_segments = activities.first.efforts.where(segment_id: segments).order(:strava_id).pluck(:segment_id)
      ordered_segments |= []
      segment_names = ['Athlete']

      ordered_segments.each do |id|
        segment_names << Segment.find_by(id: id).name
      end    
      out << segment_names
      
      activities.each do |activity|
        effort = activity.efforts.where(segment_id: segments)
        row = [activity.user.full_name]
        ordered_segments.each do |segment|
          effort = activity.efforts.find_by(segment_id: segment)
          pts = self.points.where(effort: effort).first
          if pts
            place = pts.place
          else
            place = 0
          end

          row << {'time': (effort.start_date.to_i - official_start.to_i) + effort.elapsed_time,
                  'trophy': place}

        end
        out << row
      end
      
    else
      return nil
    end

    return out
  end
  
  def set_start_date #might not need this one
    self.start_date = self.activities.pluck(:start_date).min
  end
  
  def add_feature segment, points, category
    self.featured_segments.create(segment: segment,
      val: points,
      category: category)
  end
  
  def remove_feature segment
   featured_segments.find_by(segment_id: segment.id).destroy
  end
  
  def include_activity(activity)
    activity.update(event_id: self.id)
  end
  
  def event_time
    return Time.at(self.start_date)
  end
  
  def owner
    return User.find_by(id: self.user_id)
  end
end
