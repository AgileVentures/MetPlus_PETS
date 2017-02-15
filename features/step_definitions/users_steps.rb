Given(/^I have the following Job Seekers$/) do |table|
  # table is a table.hashes.keys # => [:email, :password]
  table.hashes.each do |seeker|
    FactoryGirl.create(:job_seeker, seeker)
  end
end

Given(/^I activate user "([^"]*)"$/) do |email|
  user = User.find_by_email(email)
  expect(user.activate(user.activation_token)).to be true
end

When(/^I visit profile for "(\w+)"$/) do |first_name|
   user = User.find_by_first_name!(first_name)
   visit  "/users/edit.#{user.id}"
end

Then(/^I should verify the change of first_name "(.*?)", last_name "(.*?)" and phone "(.*?)"$/) do |first_name, last_name, phone|
    user = User.find_by_first_name(first_name)
    expect(user.last_name).to    eql last_name
    expect(user.phone).to        eql phone 
end

Then(/^I should( not)? be remembered$/) do |not_remembered|
  cookies = page.driver.cookies
  user_id = cookies['user_id']
  person_type = cookies['person_type']
  if not_remembered
    expect(user_id.expires).to be nil
    expect(person_type.expires).to be nil
  else
    expect(user_id.expires).to be_future
    expect(person_type.expires).to be_future
  end
end
j
Then(/^I should be logged out$/) do
  cookies = page.driver.cookies
  expect(cookies['person_type']).to be nil
  expect(cookies['person_id']).to be nil
end

