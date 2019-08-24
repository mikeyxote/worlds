class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def strava_test
    puts "This is a second test"
    # client = Strava::Api::Client.new(
    #   access_token: "6eedc84145199d406ba2b6f4ddebc18fb85f5148"
    #   )
    
    # activity = client.activity(2616895731)
    
    # puts activity.name
  end
  
end
