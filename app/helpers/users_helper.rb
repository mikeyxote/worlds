module UsersHelper
  
  def profile_for(user, options = { medium: true, size: 100})
    size = options['size'].to_s
    if options[:medium] == true
      profile_url = user.profile_medium
    else
      profile_url = user.profile
    end
    image_tag(profile_url, :size => "#{size}x#{size}",
                          class: "gravatar")
  end
  
  def strava_for(user)
    link_to "STRAVA!", "https://www.strava.com/athletes/" + 
    user.strava_id.to_s, target: "_blank", class: "btn btn-sm btn-strava"
  end
end
