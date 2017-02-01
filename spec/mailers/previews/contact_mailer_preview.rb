class ContactMailerPreview < ActionMailer::Preview
  def message_received
    user = { full_name: 'John Nash', email: 'johnash@gmail.com' }
    message = 'Hi!'
    ContactMailer.message_received(user, message)
  end
end
