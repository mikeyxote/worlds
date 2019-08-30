class Event < ActiveRecord::Base
  belongs_to :segment
  has_many :activities
  has_many :efforts, through: :activities
  has_many :users, through: :activities
  
  def set_start_date
    self.start_date = (self.activities.pluck(:start_date)).min
  end
  
  
end
