class ParticipationsController < ApplicationController
  before_action :logged_in_user
  
  def create
    @user = User.find(params[:managed_id])
    current_user.manage(@user)
    respond_to do |format|
      format.html { redirect_to user }
      format.js
    end
  end

  def destroy
    @user = Management.find(params[:id]).managed
    current_user.release(@user)
    respond_to do |format|
      format.html { redirect_to user }
      format.js
    end
  end
end
