class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
        
        
  def get_segment(segment_id)
    client = Strava::Api::Client.new(
        access_token: self.strava_token
      )
    
    segment = client.segment(segment_id.to_s)
    return segment
  end
  
  
  
  def test_me
    segment_id_1 = 16075104
    segment_id_2 = 64468190420
    client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
    segment_efforts = client.segment_efforts(segment_id_1.to_s)
    first_segment = segment_efforts.first
    
    segment_effort = client.segment_effort(first_segment.id)
    puts segment_effort.to_s
    
    
    # segment_efforts = client.segment_efforts(64468190475)
    # segment_effort = segment_efforts.first
    # puts segment.name
    # puts segment.id
    # puts segment.start_date_local
    # resp = client.segment_efforts(segment_id)
    # puts resp.to_s

    # activities = client.athlete_activities
    # activity = activities.first
    # # efforts = activity.segment_efforts
    # puts activity.name
    # puts activity.segment_efforts.methods
     
  end
    
  def refresh_token
    if Time.new.to_i > self.strava_expiration
      client = Strava::OAuth::Client.new(
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET']
        )
      response = client.oauth_token(
          refresh_token: self.strava_refresh_token,
          grant_type: 'refresh_token'
        )
      puts response.to_s
      self.update(strava_token: response.access_token,
            strava_refresh_token: response.refresh_token,
            strava_expiration: response.expires_at
        )
      puts "Token Refreshed"
    else
      puts "Token Valid"
    end



  end
    
  def has_strava?
    if self.strava_token != nil
      return true
    else
      return false
    end
  end
    
end