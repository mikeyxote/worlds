json.extract! series, :id, :name, :description, :start_date, :end_date, :created_at, :updated_at
json.url series_url(series, format: :json)
