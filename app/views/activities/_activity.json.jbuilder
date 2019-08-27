json.extract! activity, :id, :strava_id, :user_id, :name, :distance, :start_date, :trainer, :created_at, :updated_at
json.url activity_url(activity, format: :json)
