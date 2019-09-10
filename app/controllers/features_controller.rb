class FeaturesController < ApplicationController
  
  def create
    segment = Segment.find_by(id: params[:segment_id])
    Event.find_by(id: params[:event_id]).add_feature segment
    
  end
  
  def destroy
    segment = Segment.find_by(id: params[:segment_id])
    event = Event.find_by(id: params[:event_id])
    Feature.where(segment_id: segment.id, event_id: event.id).delete_all
  end
end
