class ApplicationMailer < ActionMailer::Base
  default from: "jersey-tracker@heroku.com"
  layout 'mailer'
  
  mail.perform_deliveries = true
end
