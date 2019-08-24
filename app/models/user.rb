class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
        
  def test_me
    puts self.strava_token
    client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
     
    # resp = client.segment_effort(64468190475)
    activities = client.athlete_activities
    activity = activities.first
    puts activity.to_s
     
  end
    
end