module UsersHelper
  

  
  def strava_for(user)
    link_to "STRAVA!", "https://www.strava.com/athletes/" + 
    user.strava_id.to_s, target: "_blank", class: "btn btn-sm btn-strava btn-pop"
  end
end
