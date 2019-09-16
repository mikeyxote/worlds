class ParticipationsController < ApplicationController
  before_action :logged_in_user
  
  def create
    @event = Event.find_by(id: params[:event_id])
    @user = User.find_by(id: params[:user_id])
    @event.register @user

    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @event = Event.find_by(id: params[:event_id])
    @user = User.find_by(id: params[:user_id])
    @event.unregister @user
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
end
