class User < ActiveRecord::Base
  has_many :activities, dependent: :destroy
  has_many :points, dependent: :destroy
  has_many :efforts, through: :activities, dependent: :destroy
  has_many :active_managements, class_name: "Management",
                      foreign_key: "manager_id",
                      dependent: :destroy
  has_many :passive_managements, class_name: "Management",
                      foreign_key: "managed_id",
                      dependent: :destroy
  has_many :managing, through: :active_managements, source: :managed
  has_many :managers, through: :passive_managements, source: :manager
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :participations, dependent: :destroy
  has_many :participating_in, through: :participations, source: :event

  def recommend
    day_hash = {}
    effort_list = []
    efforts = Effort.where(user: self.managing)
    efforts.each do |effort|
      day = effort.start_date.to_date
      if !day_hash.keys.include? day
        day_hash[day] = {effort.segment_id => Set[effort.user_id]}
      else
        if !day_hash[day].keys.include? effort.segment_id
          day_hash[day][effort.segment_id] = Set[effort.user_id]
        else
          day_hash[day][effort.segment_id] << effort.user_id
        end
      end
    end

    out = {}
    day_hash.each do |day, segments|
      segments.each do |segment, athlete_set|
        if !out.keys.include? day
          out[day] = {athlete_set => Set[segment]}
        else
          if !out[day].keys.include? athlete_set
            out[day][athlete_set] = Set[segment]
          else
            out[day][athlete_set] << segment
          end
        end
      end
    end
    out.each do |day, athlete_sets|
      athlete_sets.each do |athlete_set, segments|
        if athlete_set.size < 2 or segments.size < 3
          out[day].delete(athlete_set)
        end
      end
      if out[day] == {}
        out.delete(day)
      end
    end
    
    return out
  end

  def recommend_events
    if !self.managing? self
      self.manage self
    end
    days = []
    self.managing.each do |user|
      user_days = user.activities.where(start_date: 60.days.ago..Time.now).pluck(:start_date)
      user_days = user_days.map {|day| day.to_date}
      user_days |= []
      days += user_days
    end

    days = days.inject(Hash.new(0)) { |h,x| h[x] += 1; h}
    days = days.sort_by {|k,v| v}.reverse
    return days[0..5]
  end

  def full_name
    if self.firstname and self.lastname
      return self.firstname.titleize + " " + self.lastname.titleize
    else
      return "Your Name Here"
    end
  end

  def manage(other_user)
    active_managements.create(managed_id: other_user.id)
  end
  
  def release(other_user)
    active_managements.find_by(managed_id: other_user.id).destroy
  end

  def managing?(other_user)
    managing.include?(other_user)
  end

  def grab_five
    client = api_client
    
    all_activities = Activity.all.pluck(:strava_id)
    ingest_count = 0
    activity_list = client.athlete_activities
    activity_list.each do |activity_obj|
      if activity_obj.type == 'Ride' and not all_activities.include? activity_obj.id
        new_activity = self.activities.create(name: activity_obj.name,
                    strava_athlete_id: activity_obj.athlete['id'],
                    strava_id: activity_obj.id,
                    start_date: activity_obj.start_date,
                    trainer: activity_obj.trainer,
                    distance: activity_obj.distance)
        get_activity_efforts(new_activity.strava_id)
        ingest_count += 1
        if ingest_count >= 5
          return nil
        end
      end
    end
    return nil
  end

  def clear_all
    self.activities.delete_all
    self.efforts.delete_all
  end
  
  def api_client
    refresh_token
    client = Strava::Api::Client.new(
        access_token: self.strava_token
        )
    return client
  end
  
  def fetch_segment(segment_id)
    puts "Getting obj from Segment_id: " + segment_id.to_s
    ingest_segment_obj(get_segment_obj(segment_id))
  end
  
  def get_segment_obj(segment_id)
    client = api_client
    puts "Client assigned"
    puts "getting segment object for : " + segment_id
    segment_obj = client.segment(segment_id)
    # puts "Segment Yaml:"
    # puts segment_obj.to_yaml
    return segment_obj
  end
  
  def ingest_segment_obj(segment_obj)
    all_segments = Segment.all.pluck(:strava_id)
    if all_segments.include? segment_obj.id
      return Segment.find_by(strava_id: segment_obj.id).first
    else
      segment = Segment.create(name: segment_obj.name,
                  strava_id: segment_obj.id,
                  max_grade: segment_obj.maximum_grade,
                  average_grade: segment_obj.average_grade,
                  climb_category: segment_obj.climb_category,
                  points: 0,
                  star_count: segment_obj.star_count,
                  distance: segment_obj.distance,
                  elevation_gain: segment_obj.total_elevation_gain,
                  polyline: segment_obj.map['polyline'])
      return segment
    end
  end
  
  def update_segment segment
    segment_obj = get_segment_obj(segment.strava_id.to_s)
    segment.update(name: segment_obj.name,
                  star_count: segment_obj.star_count,
                  distance: segment_obj.distance,
                  elevation_gain: segment_obj.total_elevation_gain,
                  polyline: segment_obj.map['polyline'])
    return nil
  end
  
  def update_all_segments
    Segment.where(polyline: nil).each do |segment|
      update_segment segment
    end
    return nil
  end
  
  def get_effort_obj(effort_id)
    client = api_client
    
    effort_obj = client.segment_effort(effort_id.to_s)
    return effort_obj
  end
  
  def ingest_effort_obj(effort_obj)
    effort = Effort.create(strava_athlete_id: effort_obj.athlete['id'],
              segment_id: Segment.find_by(strava_id: effort_obj.segment['id']).id,
              strava_segment_id: effort_obj.segment['id'], # need change to foreign key for segment and add strava_segment_id in schema
              start_date: effort_obj.start_date,
              elapsed_time: effort_obj.elapsed_time,
              strava_id: effort_obj.id)
    return effort
  end
  
  def get_activity_obj(activity_id)
    client = api_client
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
    get_activity_efforts(activity_obj.id)
    return new_activity
  end
  
  def get_new_activities # can enrich with key segment triggers here
    client = api_client
    
    all_activities = Activity.all.pluck(:strava_id)
    new_activities = []

    activity_list = client.athlete_activities
    activity_list.each do |activity_obj|
      if activity_obj.type == 'Ride' and not all_activities.include? activity_obj.id
        new_activities << {name: activity_obj.name,
                    strava_athlete_id: activity_obj.athlete['id'],
                    strava_id: activity_obj.id,
                    start_date: activity_obj.start_date,
                    trainer: activity_obj.trainer,
                    distance: activity_obj.distance}
      end
    end
    return new_activities
  end
  
  def get_all_efforts
    self.activities.each do |a|
      if a.efforts.count == 0
        get_activity_efforts(a.strava_id)
      end
    end
    return nil
  end
  
  def get_activity_efforts(activity_id)
    puts "Activity ID: " + activity_id.to_s
    client = api_client
    
    activity_obj = client.activity(activity_id)
    new_activity = Activity.find_by(strava_id: activity_id)
    
    all_segments = Segment.all.pluck(:strava_id)
    activity_obj.segment_efforts.each do |effort|
      if not all_segments.include? effort.segment['id']
        ingest_segment_obj(get_segment_obj(effort.segment['id']))
      end
      new_activity.efforts.create(strava_athlete_id: effort.athlete['id'],
              user_id: new_activity.user_id,
              strava_segment_id: effort.segment['id'],
              segment_id: Segment.find_by(strava_id: effort.segment['id']).id,
              start_date: effort.start_date,
              elapsed_time: effort.elapsed_time,
              stop_date: effort.start_date + effort.elapsed_time,
              strava_id: effort.id)
    end
    
  end
  
  def fetch_activity(activity_id)
    self.refresh_token
    activity_obj = self.get_activity_obj(activity_id.to_s)
    if not Activity.all.pluck(:strava_id).include? activity_id
      self.ingest_activity_obj(activity_obj)
    else
      puts "DUPLICATE STRAVA_ID REQUESTED"
    end
    return nil
  end
  
  def test_me
    
    segments = Segment.all.pluck(:strava_id)
    puts segments.to_yaml
    Effort.all.pluck(:strava_segment_id).each do |s|
      puts "testing: " + s.to_s
      if not segments.include? s
        puts "It wasn't there"
        create_segment_from_id(s)
      end
    end
    
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