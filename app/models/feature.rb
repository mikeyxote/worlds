class Feature < ActiveRecord::Base
  belongs_to :event
  belongs_to :segment
  has_many :points, dependent: :destroy
end
