When(/^I go to the "(.+)" page$/) do |page|
  case page
    when 'JobSeeker Registration'
      visit new_jobseeker_path
    when 'homepage'
      visit root_path
  end
end

Given(/I am on the (\w+)$/) do |page|
  step "I go to the #{page} page"
end