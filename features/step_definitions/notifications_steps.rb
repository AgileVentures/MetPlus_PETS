
Then(/^I press in notification text "([^"]*)"$/) do |text|
  find('.noty_body', text: text).click
end

And(/^I should( not)? see notification "([^"]*)"/) do |not_see, text|
  error = false
  begin
    find('.noty_body', text: text)
    error = true if not_see
  rescue
    raise 'Could not find the notification' unless not_see
  end

  raise 'Notification found when should not be present' if error
end
