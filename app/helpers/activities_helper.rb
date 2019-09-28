module ActivitiesHelper
  def strava_for_activity(activity)
    link_to "STRAVA", "https://www.strava.com/activity/" + activity.strava_id.to_s, target: "_blank", class: "btn btn-sm btn-strava"
  end
  
  def activity_map polyline
    return "https://maps.googleapis.com/maps/api/staticmap?size=120x400&path=weight:3%7Cenc:#{polyline}&key=#{ENV['GOOGLE_API_KEY']}"
  end
  
  def thumbnail polyline
    base = "https://maps.googleapis.com/maps/api/staticmap?size=150x100&path=weight:3%7Ccolor:red%7Cenc:"

    url = base + polyline
    if ENV["GOOGLE_API_KEY"]
      puts "Found google static map key in environment"
      url += "&key="
      url += ENV["GOOGLE_API_KEY"]
    end
    url
  end
  
end
