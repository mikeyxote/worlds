module UsersHelper
  
  def profile_for(user, options = { medium: true })
    if options[:medium] == true
      profile_url = user.profile_medium
    else
      profile_url = user.profile
    end
    image_tag(profile_url, alt: user.username, class: "gravatar")
  end
  
end
