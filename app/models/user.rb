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
  
  def create_effort_from_id(effort_id)
    client = Strava::Api::Client.new(
        access_token: self.strava_token
      )
    
    effort = client.segment_effort(effort_id.to_s)

    Effort.create(user_id: effort.athlete['id'],
              segment_id: effort.segment['id'],
              start_date: effort.start_date.to_f,
              elapsed_time: effort.elapsed_time,
              strava_id: effort.id)
  end
  
  def create_activity_from_id(activity_id)
        client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
    
    activity = client.activity(activity_id.to_s)
    puts "Activity Name: " + activity.name
    puts "Activity ID: " + activity.id.to_s
    puts "Athlete ID: " + activity.athlete['id'].to_s
    puts "Start Date: " + activity.start_date.to_s
    puts "Trainer: " + activity.trainer.to_s
    puts "Distance: " + activity.distance.to_s
    Activity.create(name: activity.name,
                    strava_id: activity.id,
                    user_id: activity.athlete['id'],
                    start_date: activity.start_date,
                    trainer: activity.trainer,
                    distance: activity.distance)
    return nil
  end
  
  def test_me
    client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
    
    activity = client.activity(2616895731.to_s)
    puts "Activity Name: " + activity.name
    puts "Activity ID: " + activity.id.to_s
    puts "Athlete ID: " + activity.athlete['id'].to_s
    puts "Start Date: " + activity.start_date.to_s
    puts "Trainer: " + activity.trainer.to_s
    puts "Distance: " + activity.distance.to_s
    puts activity.keys.to_yaml
    
    # league_segments = Segment.all.pluck(:strava_id)
    # puts "Segment Names:"
    # activity.segment_efforts.each do |v|
    #   # puts v.segment.id
    # end
    return nil
    # puts activity.segment_efforts.first.name
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