Given(/^I have the following Job Seekers$/) do |table|
  # table is a table.hashes.keys # => [:email, :password]
  table.hashes.each do |seeker|
    FactoryGirl.create(:job_seeker, seeker)
  end
end

When(/^I fill in the fields:$/) do |table|
  # table is a table.hashes.keys # => [:First name, :John]
  table.raw.each do |field, value|
    fill_in field, :with => value
  end
  #save_and_open_page
end


Given(/^I activate user "([^"]*)"$/) do |email|
  user = User.find_by_email(email)
  expect(user.activate(user.activation_token)).to be true
end


Given(/^the following (.+) records:$/) do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end

end

Given(/^I am logged in as "(.*?)" with password "(.*?)"$/) do |email, password|

    unless email.blank? 
     visit '/login' 
     fill_in "Email", :with => email
     fill_in "Password", :with => password
     check "user_remember_me"
     click_button "Log in"
    end
   expect(page).to have_content "Signed in successfully."
end

When(/^I visit profile for "(.*?)"$/) do |first_name|
   user = User.find_by_first_name!(first_name)
   visit  "/users/edit.#{user.id}"
end


Then(/^I should verify the change of first_name "(.*?)", last_name "(.*?)" and phone "(.*?)"$/) do |first_name, last_name, phone|
    user = User.find_by_first_name(first_name)
    expect(user.last_name).to    eql last_name
    expect(user.phone).to        eql phone 
end


