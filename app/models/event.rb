class Event < ActiveRecord::Base
  belongs_to :segment
  has_many :activities
  has_many :points, dependent: :destroy
  has_many :efforts, through: :activities
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_many :featured_segments, class_name: "Feature",
                              foreign_key: "event_id",
                              dependent: :destroy
  has_many :featuring, through: :featured_segments, source: :segment
  has_many :connections, dependent: :destroy
  has_many :contains, through: :connections, source: :activity
  # belongs_to :user


  def results_table
    out = {}
    # puts "Points:"
    # puts self.points.count.to_s

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
    feature_ids = self.featuring.pluck(:id)
    segment_array = []
      
    activities.each do |activity|
      segment_array << activity.efforts.pluck(:segment_id)
    end
    flat_array = segment_array.flatten
    segment_array.each {|sa| flat_array = flat_array & sa }
    flat_array -= feature_ids
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
    # race_day = self.start_date.to_date
    # activities = Activity.where(start_date: [race_day.beginning_of_day.utc..race_day.end_of_day.utc]).where(user: self.participants)
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
    puts "----SETTING START DATE-----"
    puts "Start Dates"
    puts self.activities.pluck(:start_date).to_s
    self.start_date = self.activities.pluck(:start_date).min
  end
  
  def add_feature segment, points, category
    self.featured_segments.create(segment: segment,
      points: points,
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
