class Management < ActiveRecord::Base
  belongs_to :manager, class_name: "User"
  belongs_to :managed, class_name: "User"
  validates :manager_id, presence: true
  validates :managed_id, presence: true
end
