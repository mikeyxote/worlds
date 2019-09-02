class NewUserNotifierMailer < ApplicationMailer
  
  default :from => 'jersey-tracker@heroku.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( :to => ENV['DEFAULT_FROM_EMAIL'],
    :subject => 'New user signup at Jersey Tracker' )
  end
end
