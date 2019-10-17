class StaticPagesController < ApplicationController
  def home
    if current_user
      @results = []
      current_user.recent_events.each do |event|
        @results << event.user_result(current_user)
      end

      if current_user.has_strava?
        @points = Point.where(user_id: current_user.id).sum(:val)
        @new_activities = current_user.get_new_activities
      end
    else
      @managing = nil
      @results = nil
      @points = nil
    end
  end

  def help
  end
end
