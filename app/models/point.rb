class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :feature
  belongs_to :effort
  belongs_to :event
end
