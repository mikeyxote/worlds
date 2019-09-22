class StaticPagesController < ApplicationController
  def home
    if current_user
      @managing = current_user.managing
      @events = current_user.participating_in
      @points = Point.where(user_id: current_user.id).sum(:val)
    else
      @managing = nil
      @events = nil
      @points = nil
    end
    
  end

  def help
  end
end
