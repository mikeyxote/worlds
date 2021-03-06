class ConnectionsController < ApplicationController
  before_action :logged_in_user
  
  def create
    @event = Event.find_by(id: params[:event_id])
    @activity = Activity.find_by(id: params[:activity_id])
    @event.add_activity @activity
    @segments = @event.common_segments(@event.contains).sort_by{|s| -s.featured_by.count}
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end

  def destroy
    @event = Event.find_by(id: params[:event_id])
    @activity = Activity.find_by(id: params[:activity_id])
    @event.remove_activity @activity
    @segments = @event.common_segments(@event.contains).sort_by{|s| -s.featured_by.count}
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
  
end
