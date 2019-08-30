class User < ActiveRecord::Base
  has_many :activities, dependent: :destroy
  has_many :efforts, through: :activities
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
        
  def get_seeds
    seeds = ['2587074310',
              '2547931983',
              '2607125208',
              '2657478348',
              '2480683009',
              '2471481921',
              '2538432220',
              '2557807526']
    return seeds
  end
  
  def clear_all
    self.activities.delete_all
    self.efforts.delete_all
  end
  
  def load_seeds
    seeds = get_seeds
    seeds.each do |seed|
      fetch_activity(seed)
    end
    return nil
  end
        
  def get_segment_obj(segment_id)
    client = Strava::Api::Client.new(
        access_token: self.strava_token
        )
    
    segment_obj = client.segment(segment_id.to_s)
    return segment_obj
  end
  
  def ingest_segment_obj(segment_obj)
    segment = Segment.create(name: segment_obj.name,
                  strava_id: segment_obj.id,
                  max_grade: segment_obj.maximum_grade,
                  average_grade: segment_obj.average_grade,
                  climb_category: segment_obj.climb_category,
                  points: 0,
                  star_count: segment_obj.star_count)
    return segment
  end
  
  def get_effort_obj(effort_id)
    client = Strava::Api::Client.new(
        access_token: self.strava_token
      )
    
    effort_obj = client.segment_effort(effort_id.to_s)
    return effort_obj
  end
  
  def ingest_effort_obj(effort_obj)
    effort = Effort.create(strava_athlete_id: effort_obj.athlete['id'],
              segment_id: effort_obj.segment['id'],
              start_date: effort_obj.start_date.to_f,
              elapsed_time: effort_obj.elapsed_time,
              strava_id: effort_obj.id)
    return effort
  end
  
  def get_activity_obj(activity_id)
    client = Strava::Api::Client.new(
      access_token: self.strava_token
    )
    activity_obj = client.activity(activity_id.to_s)
    return activity_obj
  end
  
  def ingest_activity_obj(activity_obj)
    new_activity = self.activities.create(name: activity_obj.name,
                    strava_athlete_id: activity_obj.athlete['id'],
                    strava_id: activity_obj.id,
                    start_date: activity_obj.start_date,
                    trainer: activity_obj.trainer,
                    distance: activity_obj.distance)
    
    all_segments = Segment.all.pluck(:strava_id)
    activity_obj.segment_efforts.each do |effort|
      if not all_segments.include? effort.segment['id']
        ingest_segment_obj(get_segment_obj(effort.segment['id']))
      end
      new_activity.efforts.create(strava_athlete_id: effort.athlete['id'],
              user_id: new_activity.user_id,
              segment_id: effort.segment['id'],
              start_date: effort.start_date.to_f,
              elapsed_time: effort.elapsed_time,
              strava_id: effort.id)
    end
    
    return new_activity
  end
  
  def fetch_activity(activity_id)
    activity_obj = self.get_activity_obj(activity_id)
    self.ingest_activity_obj(activity_obj)
    return nil
  end
  
  def test_me
    # client = Strava::Api::Client.new(
    #   access_token: self.strava_token
    # )
    
    segments = Segment.all.pluck(:strava_id)
    puts segments.to_yaml
    Effort.all.pluck(:segment_id).each do |s|
      puts "testing: " + s.to_s
      if not segments.include? s
        puts "It wasn't there"
        create_segment_from_id(s)
      end
    end
      
      
    # activity = client.activity(2616895731.to_s)
    # puts "Activity Name: " + activity.name
    # puts "Activity ID: " + activity.id.to_s
    # puts "Athlete ID: " + activity.athlete['id'].to_s
    # puts "Start Date: " + activity.start_date.to_s
    # puts "Trainer: " + activity.trainer.to_s
    # puts "Distance: " + activity.distance.to_s
    # puts activity.keys.to_yaml
    
    # league_segments = Segment.all.pluck(:strava_id)
    # puts "Segment Names:"
    # activity.segment_efforts.each do |v|
    #   # puts v.segment.id
    # end
    return nil
     
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