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
      segments << {'polyline': f.segment.polyline,
                    'name': f.segment.name,
                    'category': f.category}
    end
    winners = [] # array of end-segment-locs/winner-icons
    self.points.where(place: 1).each do |pt|
      winners << {'endpoint': pt.feature.segment.endpoint,
                  'profile': User.find_by(id: pt.user_id).profile}
    end
    
    out =  {'route': route,
            'segments': segments,
            'winners': winners}
    return out
  end

  def polyline2hash(polyline)
    array = Polylines::Decoder.decode_polyline(polyline)
    # puts "Array in polyline2hash" + array.to_s
    # puts "Array in polyline2hash count: " + array.length.to_s
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
    puts "Starting ---------------"
    puts "users Count:"
    puts users.count.to_s
    puts "segment Count:"
    puts segments.count.to_s
    name = d.strftime('%a, %d %b %Y').to_s if name == nil
    event = Event.create(start_date: d,
                        name: name)
    if owner == nil
      owner = User.where(developer: true).first 
    end
    event.update(user_id: owner.id) if owner != nil
    event.update(segment_id: end_segment.id) if end_segment != nil
    puts event.to_json
    puts "Connecting Segments ---------------"
    if segments
      puts "We have segments"
      segments.each do |segment|
        # puts segment.class.to_s
        # puts segment.id
        # puts segment.to_json
        
        Feature.create(segment_id: segment.id,
                        event_id: event.id,
                        category: 'sprint',
                        val: 6)
        # event.add_feature(segment, '5', 'sprint')
      end
    end
    puts "Connecting Users ---------------"
    if users and segments
      segment_ids = event.featuring.pluck(:segment_id)
      users.each do |user|
        user.activities.where(start_date: [event.start_date.beginning_of_day..event.start_date.end_of_day]).each do |activity|
          puts "Found activities for " + user.full_name
          puts activity.name
          puts Set[segment_ids].to_json
          puts Set[activity.efforts.pluck(:segment_id)].to_json
          segment_set = segment_ids.to_set
          activity_set = activity.efforts.pluck(:segment_id).to_set
          puts segment_set.to_json
          puts activity_set.to_json
          if segment_set.subset? activity_set
            puts "Subset Found"
            event.make_connection activity
          end
        end
      end
    end
    puts "Finishing ---------------"
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
    # self.points.where(user: user).where(place: 1).group(:category).count(:place)
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
      puts "User IDs:"
      puts user_id.to_s
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
    # feature_ids = self.featuring.pluck(:id)
    segment_array = []
      
    activities.each do |activity|
      segment_array << activity.efforts.pluck(:segment_id)
    end
    flat_array = segment_array.flatten
    segment_array.each {|sa| flat_array = flat_array & sa }
    # flat_array -= feature_ids
    return Segment.where(id: flat_array)
  end
  
  def ride_segments_old
    segment_hash = {}
    efforts = Effort.where(activity: self.contains)
    efforts.each do |effort|
      sid = effort.segment_id
      if !segment_hash.keys.include? sid
        segment_hash[sid] = Set[effort.user_id]
      else
        segment_hash[sid] << effort.user_id
      end
    end
    
    users_hash = {}
    
    segment_hash.each do |segment, athlete_set|
      if !users_hash.keys.include? athlete_set
        users_hash[athlete_set] = Set[segment]
      else
        users_hash[athlete_set] << segment
      end
    end
    out_hash = {}
    users_hash.each do |users, segments|
      if !array_subset(users, out_hash.keys)
        out_hash[users] = segments
      end
    end
    return out_hash
  end

  def add_activity activity
    Connection.create(event_id: self.id, activity_id: activity.id)
  end
  
  def remove_activity activity
    connections.where(activity_id: activity.id).destroy_all
  end
  
  def get_table
    puts "----Starting get_table-----"

    out = []
    activities = self.contains
    activity_ids = activities.pluck(:id)
    if activities.count > 0
      self.start_date = activities.pluck(:start_date).min
    end

    official_start = self.start_date
    segments = self.featuring.pluck(:id)
    if activities.size > 0
      # compute winning data here and assign points
      Point.where(event: self).delete_all
      self.featured_segments.each do |feature|
        winning_efforts = feature.segment.efforts.where(activity_id: activity_ids).order(:stop_date).limit(3)
        # feature = Feature.where(segment_id: segment_id).where(event_id: self.id).first
        
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
          # place = self.points.where(effort: effort).first.place || 0
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
