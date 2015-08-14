Given(/^I have the following Job Seekers$/) do |table|
  # table is a table.hashes.keys # => [:email, :password]
  table.hashes.each do |seeker|
    FactoryGirl.create(:job_seeker, seeker)
  end
end

When(/^I fill in the fields$/) do |table|
  # table is a table.hashes.keys # => [:First name, :John]
  table.raw.each do |field, value|
    fill_in field, :with => value
  end
end


Given(/^I activate user "([^"]*)"$/) do |email|
  user = User.find_by_email(email)
  expect(user.activate(user.activation_token)).to be true
end