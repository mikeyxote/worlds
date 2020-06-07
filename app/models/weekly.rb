class Weekly < ActiveRecord::Base
  belongs_to :segment
  belongs_to :user
  belongs_to :team
  
  def placements
    efforts = self.segment.efforts.where(user_id: self.team.members.pluck(:id)).where(:start_date => self.start_date..self.end_date)
    # best_efforts = efforts.order(:elapsed_time)
    return efforts
  end
  
  def entry_count
    return self.placements.count
  end
  
  def winner
    self.placements.order(elapsed_time: :desc).first
  end
  
  
end
