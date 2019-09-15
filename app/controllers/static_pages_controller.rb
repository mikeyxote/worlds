class StaticPagesController < ApplicationController
  def home
    if current_user
      @managing = current_user.managing
    else
      @managing = nil
    end
  end

  def help
  end
end
