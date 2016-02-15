When(/^I go to the (.+) page$/) do |page|
  case page
    
    when 'job creation'
      visit new_job_path  
    when 'Company Registration'
      visit new_company_registration_path 
    when 'Jobseeker Registration'
      visit new_job_seeker_path
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

Given(/I am on the (.+) page$/) do |page|
  step "I go to the #{page} page"
end

Then(/^I should be on the (.+) page$/) do |page|
  step "I go to the #{page} page"
end


