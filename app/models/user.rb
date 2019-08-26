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
    
    effort = client.segment_effort(effort_id)
    puts effort.name
    puts effort.athlete['id']
    puts effort.activity['id']
    puts effort.start_date.to_f
    puts effort.elapsed_time
    puts effort.segment['id']
    puts effort.id
    
    Effort.create(user_id: effort.athlete['id'],
              segment_id: effort.segment['id'],
              start_date: effort.start_date.to_f,
              elapsed_time: effort.elapsed_time,
              strava_id: effort.id)

    
  end
  
  def test_me
    client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
    
    # activities = client.athlete_activities
    # last_activity = activities.third
    # efforts = activity.segment_efforts
    # puts last_activity.name
    # puts last_activity.id
    activity = client.activity(2616895731.to_s)
    puts "Activity Name: " + activity.name
    puts "Activity ID: " + activity.id.to_s
    league_segments = Segment.all.pluck(:strava_id)
    puts "Segment Names:"
    activity.segment_efforts.each do |v|
      # puts v.segment.id
      if league_segments.include? v.segment.id
        puts v.name
        puts v.activity
        puts "Started: " + v.start_date.to_s
        puts "Elapsed time: " + v.elapsed_time.to_s
        puts "Completed at: " + Time.at(v.start_date.to_f + v.elapsed_time).to_s
        # puts v.start_date.to_f
        # puts v.moving_time
        # puts v.elapsed_time
        # puts v.time
        # puts v.to_yaml
        puts "------"
      end
    end
    return nil
    # puts activity.segment_efforts.first.name
    # puts activity.segment_efforts.methods
    
    
    
    # segment_efforts = client.segment_efforts(segment_id_1.to_s)
    # first_segment = segment_efforts.first
    
    # segment_effort = client.segment_effort(first_segment.id)
    # puts segment_effort.to_s
    
    
    # segment_efforts = client.segment_efforts(64468190475)
    # segment_effort = segment_efforts.first
    # puts segment.name
    # puts segment.id
    # puts segment.start_date_local
    # resp = client.segment_efforts(segment_id)
    # puts resp.to_s

    
     
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