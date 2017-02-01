class ContactMailer < ApplicationMailer
  def message_received(user, message)
    @name = user[:full_name]
    @email = user[:email]
    @message = message
    mail(to: ENV['ADMIN_EMAIL'],
         from: ENV['NOTIFICATION_EMAIL'],
         subject: 'Inquiry received from "contact us" PETS page')
  end
end
