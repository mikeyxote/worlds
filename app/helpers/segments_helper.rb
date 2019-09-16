module SegmentsHelper
  def strava_for_segment(segment)
    link_to "STRAVA", "https://www.strava.com/segments/" + segment.strava_id.to_s, target: "_blank", class: "btn btn-sm btn-strava"
  end
end
