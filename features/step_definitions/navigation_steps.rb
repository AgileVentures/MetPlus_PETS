When(/^I go to the (.+) page$/) do |page|
  case page
    when 'JobSeeker Registration'
      visit new_jobseeker_path
    when 'home'
      visit root_path
    when /activation for user '.+'/
      user = page.match(/'(.+)'/)
      if user[1] =~ /@/
        visit activate_user_path(User.find_by_email(user[1]).activation_token)
      else
        visit activate_user_path user
      end
  end
end

Given(/I am on the (\w+) page$/) do |page|
  step "I go to the #{page} page"
end
Given(/^I am on the Jobseeker Registration page$/) do
  visit "/job_seekers/new"
end

