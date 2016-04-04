
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
    when /agency '(.+)' edit/
      agency = page.match(/'(.+)'/)
      visit edit_agency_path(Agency.find_by_name(agency[1]))
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

Given(/I am on the JobSeeker Show page for "([^"]*)"$/) do |email|
  visit job_seeker_path(User.find_by_email(email).actable_id)
end

Given(/^I am on the Job edit page with given record:$/) do 
  job = FactoryGirl.create(:job)
  visit edit_job_path(job.id)
end
