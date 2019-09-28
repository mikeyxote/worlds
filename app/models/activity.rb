class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :efforts, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :part_of, through: :connections, source: :event
end
