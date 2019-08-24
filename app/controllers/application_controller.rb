class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  

  # # Returns the current logged-in user (if any).
  # def current_user
  #   if session[:user_id]
  #     @current_user ||= User.find_by(id: session[:user_id])
  #   end
  # end

  # # Returns true if the user is logged in, false otherwise.
  # def logged_in?
  #   !current_user.nil?
  # end

end