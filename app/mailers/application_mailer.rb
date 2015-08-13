class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@metplus.org"
  layout 'mailer'
end
