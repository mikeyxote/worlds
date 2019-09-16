module ActivitiesHelper
  def strava_for_activity(activity)
    link_to "STRAVA", "https://www.strava.com/activity/" + activity.strava_id.to_s, target: "_blank", class: "btn btn-sm btn-strava"
  end
end
