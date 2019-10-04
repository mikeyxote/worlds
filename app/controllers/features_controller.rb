class FeaturesController < ApplicationController
  before_action :logged_in_user
  
  def create
    puts "FeatureController Params:"
    puts params.to_yaml
    
    # segment = Segment.find_by(id: params[:segment_id])
    # pts = params[:feature][:pts].to_s
    Feature.create(event_id: params[:event_id], 
                    segment_id: params[:segment_id],
                    val: params['feature']['pts'],
                    category: params[:commit].downcase)
    # Event.find_by(id: params[:event_id]).add_feature(segment, 
    #                                     params[:points], 
    #                                     params[:category])
    respond_to do |format|
      format.html { redirect_to Event.find_by(id: params[:event_id])}
      format.js
    end
  end
  
  def destroy
    segment = Segment.find_by(id: params[:segment_id])
    event = Event.find_by(id: params[:event_id])
    features = Feature.where(segment_id: segment.id, event_id: event.id)
    Point.where(feature: features).delete_all
    features.delete_all
    respond_to do |format|
      format.html { redirect_to Event.find_by(id: params[:event_id]) }
      format.js
    end
  end
end
