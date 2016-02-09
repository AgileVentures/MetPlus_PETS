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

Then(/^I should verify the change of title "(.*?)", shift "(.*?)" and jobId "(.*?)"$/) do |title, shift, jobId|
  # pending # express the regexp above with the code you wish you had
  job = Job.find_by_title(title)
  expect(job.shift).to eql shift
  expect(job.jodId).to eql jobId 

end

Then(/^I should verify the change of first_name "(.*?)", last_name "(.*?)" and phone "(.*?)"$/) do |first_name, last_name, phone|
    user = User.find_by_first_name(first_name)
    expect(user.last_name).to    eql last_name
    expect(user.phone).to        eql phone 
end


