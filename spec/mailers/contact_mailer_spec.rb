require 'rails_helper'

RSpec.describe ContactMailer, type: :mailer do
  describe 'message_received' do
    let(:user) do
      {
        first_name: 'John',
        surname: 'Nash',
        email: 'johnash@gmail.com'
      }
    end
    let(:message) { 'Hi' }
    let(:mail) { ContactMailer.message_received(user, message) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Inquiry received from "contact us" PETS page')
      expect(mail.to).to eq([ENV['ADMIN_EMAIL']])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end

    it 'renders the message text' do
      expect(mail.body.encoded).to match(message)
    end
  end
end
