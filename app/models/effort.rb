class Effort < ActiveRecord::Base
  belongs_to :user
  belongs_to :segment
  belongs_to :activity
  has_many :points, dependent: :destroy
  
  def update_stop
    stop_date = self.start_date + self.elapsed_time
    self.update(stop_date: stop_date)
    return nil
  end

end
