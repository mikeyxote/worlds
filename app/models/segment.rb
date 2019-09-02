class Segment < ActiveRecord::Base
  has_many :featured_by, class_name: "Feature",
                        foreign_key: "event_id",
                        dependent: :destroy
end
