class Series < ActiveRecord::Base
  has_many :races, dependent: :destroy
  has_many :events
                  
  def add_event event
    event.update(series_id: self.id)
    # Race.create(event: event, series: self)
  end
end
