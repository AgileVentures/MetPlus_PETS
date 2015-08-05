Given(/^I have the following Job Seekers$/) do |table|
  # table is a table.hashes.keys # => [:email, :password]
  table.hashes.each do |seeker|
    FactoryGirl.build(:job_seeker, seeker).save!
  end
end

When(/^I fill in the fields$/) do |table|
  # table is a table.hashes.keys # => [:First name, :John]
  table.raw.each do |field, value|
    fill_in field, :with => value
  end
end
