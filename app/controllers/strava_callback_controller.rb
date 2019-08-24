class StravaCallbackController < ApplicationController
    
  def show
    if params[:code]
      code = params[:code]
      puts "Code found"
      puts code
      client = Strava::OAuth::Client.new(
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET']
        )
      
      
      # strava_secret = ENV['STRAVA_SECRET']
      # client_id = ENV['STRAVA_CLIENT_ID'].to_i
      response = client.oauth_token(code: code)
      
      puts response.to_s
      @incoming_info = response.to_s
      current_user.update(
        strava_token: response.access_token,
        strava_refresh_token: response.refresh_token,
        strava_expiration: response.expires_at,
        strava_id: response.athlete.id,
        name: response.athlete.username,
        avatar: response.athlete.profile_medium
        )
      puts "Athlete Number:"
      # puts response.athlete['id']
      puts response.athlete.id
      @avatar = response.athlete.profile_medium
      # access_information = Strava::Api::V3::Auth.retrieve_access(client_id, 
      #                                                           strava_secret, code)
      # puts "Access Information:"
      # puts access_information.to_s
      # if new_user_token = access_information['access_token']
      #   current_user.update(strava_token: new_user_token, strava_enabled: true)
        
        
      #   @message = "Success!"
      # else
      #   @message = "Code was present but access exchanges failed."
      # end
      @message = "Success"
    else
      @message = "Code not present in URL query string"
    end
  end
end
