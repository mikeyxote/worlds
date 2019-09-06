class Segment < ActiveRecord::Base
  has_many :featured_by, class_name: "Feature",
                        foreign_key: "segment_id",
                        dependent: :destroy
                        
                        
  def featured? event
    if event.featured_segments.pluck(:id).include? id
      return true
    else
      return false
    end
  end
end
