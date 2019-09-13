class FeaturesController < ApplicationController
  before_action :logged_in_user
  
  def create
    segment = Segment.find_by(id: params[:segment_id])
    Event.find_by(id: params[:event_id]).add_feature segment
    respond_to do |format|
      format.html { redirect_to Event.find_by(id: params[:event_id])}
      format.js
    end
  end
  
  def destroy
    segment = Segment.find_by(id: params[:segment_id])
    event = Event.find_by(id: params[:event_id])
    Feature.where(segment_id: segment.id, event_id: event.id).delete_all
    respond_to do |format|
      format.html { redirect_to Event.find_by(id: params[:event_id]) }
      format.js
    end
  end
end
