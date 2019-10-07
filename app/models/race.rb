class Race < ActiveRecord::Base
  belongs_to :series
  belongs_to :event
end
