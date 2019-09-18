class Segment < ActiveRecord::Base
  has_many :featured_by, class_name: "Feature",
                        foreign_key: "segment_id",
                        dependent: :destroy
  has_many :efforts, dependent: :destroy
  
                
  def user_count
    Effort.where(strava_segment_id: self.strava_id).group(:user_id).size.size
  end
                        
  def featured? event
    if event.featured_segments.pluck(:segment_id).include? self.id
      return true
    else
      return false
    end
  end
end
