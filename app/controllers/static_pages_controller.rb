class StaticPagesController < ApplicationController
  def home
    @managing = current_user.managing
  end

  def help
  end
end
