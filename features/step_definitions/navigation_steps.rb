def page_translator(name)
  case name
  when 'job creation'
    new_job_path
  when 'Company Registration'
    new_company_registration_path
  when 'Jobseeker Registration'
    new_job_seeker_path
  when 'home'
    root_path
  when 'tasks'
    tasks_path
  when 'jobs'
    jobs_path
  when /Job Seeker '.+' job match/
    user = name.match(/'(.+)'/)
    list_match_jobs_job_seeker_path(
      User.find_by_email(user[1]).pets_user
    )
  when /Job Seeker '.+' Home/
    user = name.match(/'(.+)'/)
    home_job_seeker_path(User.find_by_email(user[1]).pets_user)
  when /Company Person '.+' Home/
    user = name.match(/'(.+)'/)
    home_company_person_path(User.find_by_email(user[1]).pets_user)
  when /Agency Person '.+' Home/
    user = name.match(/'(.+)'/)
    home_agency_person_path(User.find_by_email(user[1]).pets_user)
  when /'.+' edit profile/
    user = name.match(/'(.+)'/)
    user = User.find_by_email(user[1]).pets_user
    return edit_job_seeker_path user if user.is_job_seeker?
    return edit_profile_company_person_path user if user.is_a? CompanyPerson
    return edit_profile_agency_person_path user if user.is_a? AgencyPerson
  when /'.+' profile/
    user = name.match(/'(.+)'/)
    user = User.find_by_email(user[1]).pets_user
    return my_profile_job_seeker_path user if user.is_job_seeker?
    return my_profile_company_person_path user if user.is_a? CompanyPerson
    return my_profile_agency_person_path user if user.is_a? AgencyPerson
  when /agency '(.+)' edit/
    agency = name.match(/'(.+)'/)
    edit_agency_path(Agency.find_by_name(agency[1]))
  when /Company person '(.+)' show/
    user = name.match(/'(.+)'/)
    company_person_path(User.find_by_email(user[1]).pets_user)
  when /activation for user '.+'/
    user = name.match(/'(.+)'/)
    if user[1] =~ /@/
      return activate_user_path(User.find_by_email(user[1]).activation_token)
    else
      return activate_user_path user
    end
  end
end

When(/^I type agency_admin home in the URL address bar/) do
  current_path = URI.parse(current_url).path
  current_path.replace '/agency_admin/home'
  visit current_path
end

When(/^I go to the (.+) page$/) do |page|
  visit page_translator(page)
end

Given(/I am on the (.+) page$/) do |page|
  step "I go to the #{page} page"
end

Then(/^I should be on the (.+) page$/) do |page_name|
  expect(current_path).to eq(page_translator(page_name))
end

Given(/I am on the JobSeeker Show page for "([^"]*)"$/) do |email|
  visit job_seeker_path(User.find_by_email(email).actable_id)
end

Then(/^I press the Job Match button for '(.+)'$/) do |email|
  find("#match-job-#{User.find_by_email(email).actable_id}").click
end
