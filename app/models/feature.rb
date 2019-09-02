class Feature < ActiveRecord::Base
  belongs_to :event
  belongs_to :segment
end
