class StravaCallbackController < ApplicationController
    
  def show
    if params[:code]
      code = params[:code]
      client = Strava::OAuth::Client.new(
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET']
        )
      
      response = client.oauth_token(code: code)
      
      current_user.update(
        strava_token: response.access_token,
        strava_refresh_token: response.refresh_token,
        strava_expiration: response.expires_at,
        strava_id: response.athlete.id,
        firstname: response.athlete.firstname,
        lastname: response.athlete.lastname,
        username: response.athlete.username,
        profile_medium: response.athlete.profile_medium,
        profile: response.athlete.profile
        )
      current_user.user_initiate
      @avatar = response.athlete.profile_medium

      @message = "Success"
    else
      @message = "Code not present in URL query string"
    end
  end
end
