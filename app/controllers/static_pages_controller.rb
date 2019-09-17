class StaticPagesController < ApplicationController
  def home
    if current_user
      @managing = current_user.managing
    else
      @managing = nil
    end
    @events = current_user.participating_in
    @points = Point.where(user_id: current_user.id)
    
    
  end

  def help
  end
end
