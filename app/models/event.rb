class Event < ActiveRecord::Base
  belongs_to :segment
  has_many :activities
  has_many :efforts, through: :activities
  has_many :users, through: :activities
  has_many :featured_segments, class_name: "Feature",
                              foreign_key: "segment_id",
                              dependent: :destroy
  
  def set_start_date
    self.start_date = (self.activities.pluck(:start_date)).min
  end
  
  def add_feature segment
    Feature.create(event_id: self.id, segment_id: segment.id)
  end
  
  def include_activity(activity)
    activity.update(event_id: self.id)
  end
  
end
