class StravaCallbackController < ApplicationController
    
  def show
    if params[:code]
      code = params[:code]
      client = Strava::OAuth::Client.new(
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET']
        )
      
      response = client.oauth_token(code: code)
      
      # puts response.to_s
      # @incoming_info = response.to_s
      current_user.update(
        strava_token: response.access_token,
        strava_refresh_token: response.refresh_token,
        strava_expiration: response.expires_at,
        strava_id: response.athlete.id,
        name: response.athlete.username,
        avatar: response.athlete.profile_medium
        )
      @avatar = response.athlete.profile_medium

      @message = "Success"
    else
      @message = "Code not present in URL query string"
    end
  end
end
