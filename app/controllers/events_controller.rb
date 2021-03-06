class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :featured_segments]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
    @alt_recommends = current_user.recommend
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @segments = []
    if @event.start_date
      race_day = @event.start_date.to_date
      @activities = Activity.where(start_date: [race_day.beginning_of_day..race_day.end_of_day])
      @features = @event.featured_segments
      @connections = @event.contains
      if @event.activities.count > 0 and @event.features.count > 0
        @showmap = true
      else
        @showmap = false
      end
      if @event.activities.count > 0
        gmap = @event.get_gmap
        
        @route = gmap[:route]
        @map_segments = gmap[:segments]
        @hash = Gmaps4rails.build_markers(gmap[:winners]) do |pt, marker|
          marker.lat pt[:endpoint][0]
          marker.lng pt[:endpoint][1]
          
          marker.infowindow pt[:user].full_name
          marker.picture({
              # url: pt[:profile],
              marker_anchor: [0,50],
              width: '50',
              height: '50',
              scaledSize: [20,20],
              scaledWidth: '10',
              scaledHeight: '10'
              })
        end
      end

      @segments = @event.common_segments(@event.contains).sort_by{|s| -s.featured_by.count}
      
      @table = @event.get_table
      @event.make_results
      @results = @event.results.order(:place)
      puts "Route----------------------"
      puts @route
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.update(user_id: params['user_id'],
                  segment_id: params['event']['segment'],
                  series_id: params['event']['series'])
    respond_to do |format|
      if @event.save
        # series = Series.find_by(id: params['series '])
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # def update_segments
  #   @segments = @event.common_segments(@event.contains).sort_by{|s| -s.featured_by.count}
  # end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        @event.update(series_id: params['event']['series'])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    puts "I'm triggering the destroy method in the events controller"
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :start_date, :segment_id)
    end
end
