class ApplicationMailer < ActionMailer::Base
  default from: Settings.email_from_address
  layout Settings.mailer_layout
end
