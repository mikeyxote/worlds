class User < ActiveRecord::Base
        
    def test_me
        puts "Starting Test"
        # client = Strava::Api::Client.new(
        #   access_token: "7ca3ca594e681742c160bf7ec5747b123520111a"
        #   )
        puts ENV['STRAVA_CLIENT_ID']
        puts ENV['STRAVA_CLIENT_SECRET']
        puts ENV['C9_PORT']
        # activity = client.activity('2629877614')
        
        # puts activity.name
        
    end
    
end
