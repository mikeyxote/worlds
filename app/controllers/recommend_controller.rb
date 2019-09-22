class RecommendController < ApplicationController
  def create
    start_date = params[:start_date]
    athletes = params[:athletes]
    event = Event.create(user_id: current_user.id,
                        start_date: start_date, 
                        name: start_date.to_s)
    user_ids = JSON.parse(athletes)
    # user_ids = athletes
    user_ids.each do |user_id|
      event.register User.find_by(id: user_id)
    end
    redirect_to event
    
  end
end
