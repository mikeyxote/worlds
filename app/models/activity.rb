class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :efforts, dependent: :destroy
end
