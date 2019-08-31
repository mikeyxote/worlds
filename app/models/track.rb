class Track
  attr_accessor :strava_id, :start_date, :efforts, :name, :athlete_id
  def initialize(activity, start_date)
    @start_date = start_date
    @strava_id = activity.strava_id
    @athlete = activity.strava_athlete_id
    @efforts = []
    @name = activity.name
    @athlete_id = activity.strava_athlete_id
    @featured = [5472811, 13750586, 5113112, 675023, 1039537, 11744697, 5526446]
  end
  
  def add_effort(effort)
    if @featured.include? effort.segment_id
      @efforts << effort
    end
    @efforts.sort_by{|obj| obj.start_date}
  end
  
end