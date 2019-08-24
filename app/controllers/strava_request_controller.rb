class StravaRequestController < ApplicationController
  def show
    
    
    # client = Strava::OAuth::Client.new(
    #     client_id: ENV['STRAVA_CLIENT_ID'],
    #     client_secret: ENV['STRAVA_SECRET']
    #   )
      
    # @redirect_url = client.authorize_url(
    #   redirect_uri: 'https://0dbef404a85c424faff93688f927425e.vfs.cloud9.us-west-2.amazonaws.com/strava_callback',
    #   approval_prompt: 'force',
    #   response_type: 'code',
    #   scope: 'activity:read_all',
    #   state: 'request'
    #   )
      
    
    @strava_url = "https://www.strava.com/oauth/authorize"
    redirect_uri = 'https://0dbef404a85c424faff93688f927425e.vfs.cloud9.us-west-2.amazonaws.com/strava_callback'
    @client_id = ENV['STRAVA_CLIENT_ID'].to_i
    
    @strava_params = {client_id: @client_id,
                      redirect_uri: redirect_uri,
                      response_type: "code",
                      scope: 'activity:read_all',
                      state: 'strava_request'
    }
    uri = URI(@strava_url)
    uri.query = @strava_params.to_query
    @full_uri = uri.to_s
    puts "Sending uri to " + uri.to_s
  end
end
