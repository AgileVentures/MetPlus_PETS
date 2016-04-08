def page_translator name
  case name

    when 'job creation'
      return new_job_path
    when 'Company Registration'
      return new_company_registration_path
    when 'Jobseeker Registration'
      return new_job_seeker_path
    when 'home'
      return root_path
    when /Job Seeker '.+' Home/
      user = page.match(/'(.+)'/)
      return job_seeker_home_path(User.find_by_email(user[1]))
    when /activation for user '.+'/
      user = page.match(/'(.+)'/)
      if user[1] =~ /@/
        return activate_user_path(User.find_by_email(user[1]).activation_token)
      else
        return activate_user_path user
      end
  end
end


When(/^I go to the (.+) page$/) do |page|
  visit page_translator(page)
end

Given(/I am on the (.+) page$/) do |page|
  step "I go to the #{page} page"
end

Then(/^I should be on the (.+) page$/) do |page|
  expect(current_path).to eq(page_translator(page))
end

Given(/I am on the JobSeeker Show page for "([^"]*)"$/) do |email|
  visit job_seeker_path(User.find_by_email(email).actable_id)
end

Given(/^I am on the Job edit page with given record:$/) do 
  job = FactoryGirl.create(:job)
  visit edit_job_path(job.id)
end
