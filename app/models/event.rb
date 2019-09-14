class Event < ActiveRecord::Base
  belongs_to :segment
  has_many :activities
  has_many :efforts, through: :activities
  has_many :users, through: :activities
  has_many :featured_segments, class_name: "Feature",
                              foreign_key: "event_id",
                              dependent: :destroy
  has_many :featuring, through: :featured_segments, source: :segment
  # belongs_to :user

  def get_table
    puts "----Starting get_table-----"

    out = []
    race_day = self.start_date.to_date
    activities = Activity.where(start_date: [race_day.beginning_of_day..race_day.end_of_day])

    if activities.count > 0
      self.start_date = activities.pluck(:start_date).min
    end

    official_start = self.start_date
    segments = self.featuring.pluck(:id)
    ordered_segments = activities.first.efforts.where(segment_id: segments).order(:strava_id).pluck(:segment_id)
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
        row << (effort.start_date.to_i - official_start.to_i) + effort.elapsed_time
      end
      out << row
    end
        
    return out
  end
  
  def set_start_date #might not need this one
    puts "----SETTING START DATE-----"
    puts "Start Dates"
    puts self.activities.pluck(:start_date).to_s
    self.start_date = self.activities.pluck(:start_date).min
  end
  
  def add_feature segment
    Feature.create(event_id: self.id, segment_id: segment.id)
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
