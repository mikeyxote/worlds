class Series < ActiveRecord::Base
  has_many :races, dependent: :destroy
  has_many :events, through: :races
                  
  def add_event event
    Race.create(event: event, series: self)
  end
end
