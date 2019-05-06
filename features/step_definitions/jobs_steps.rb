Then(/^I should verify the change of title "(.*?)" and jobId "(.*?)"$/) do |title, job_id|
  @job = Job.find_by_title(title)
  expect(@job.company_job_id).to eql job_id
end

Then(/^I should see a popup with the following job information$/) do
  expect(page).to have_content("Are you sure you want
             to delete the following job:
                 job title:  #{@job.title}
                 job id: #{@job.company_job_id}")
end

Given(/^the Widgets, Inc\. company name with address exist in the record$/) do
  FactoryBot.create(:company)
end

Then(/^I (?:visit the |return to )jobs page$/) do
  @job = nil
  visit jobs_path
end

Then(/^I should( not)? see "Revoked" next to "([^"]*)"$/) do |negate, job_title|
  @job ||= Job.find_by(title: job_title)
  if negate
    expect(page).not_to have_selector(:xpath, "//tr[td[contains(.,
    '#{job_title}')]]/td/span", text: 'Revoked')
  else
    expect(page).to have_selector(:xpath, "//tr[td[contains(.,
    '#{job_title}')]]/td/span", text: 'Revoked')
  end
end

Then(/^I should see the job status is "([^"]*)"$/) do |status|
  within('#job-status') { expect(page).to have_content status.to_s }
end

Then(/^I should see a "([^"]*)" confirmation$/) do |action|
  expect(page).to have_content('Are you sure you want ' \
  "to #{action} the following job: " \
  "job title: #{@job.title} " \
  "company job id: #{@job.company_job_id} ", normalize_ws: true)
end

Then(/^I should( not)? see "Revoke" link on the page$/) do |negate|
  if negate
    expect(page).not_to have_css('a#revoke_link', text: 'Revoke')
  else
    expect(page).to have_css('a#revoke_link', text: 'Revoke')
  end
end

Then(/^I click the Revoke confirmation for "([^"]*)"$/) do |job_title|
  @job ||= Job.find_by(title: job_title)
  find('#confirm_revoke').click
end

Then(/^I click the "([^"]*)" link to job show page$/) do |job_title|
  @job ||= Job.find_by(title: job_title)
  find("a[href='/jobs/#{@job.id}']").click
end

Then(/^I apply to "([^"]*)" from Jobs link(?: again)?$/) do |job_title|
  step %(I click the "Jobs" link)
  step %(I click the "#{job_title}" link)
  step %(I click the "Click Here To Apply Online" link)
  step %(I wait for 1 second)
  step %(I should see "Job Application")
  step %(I click the "Apply Now" button)
end

Then(/^I want to apply to "([^"]*)" for "(?:[^"]*)"$/) do |job_title|
  step %(I visit the jobs page)
  step %(I click the "#{job_title}" link)
  step %(I click the "Click Here to Submit an Application for Job Seeker" link)
end

And(/^I find "([^"]*)" from my job seekers list and proceed with the application$/) do |job_seeker|
  step %(I select2 "#{job_seeker}" from "jd_apply_job_select")
  step %(I press "Proceed")
end

Then(/^I apply to "([^"]*)" for my job seeker: "([^"]*)"$/) do |job_title, job_seeker|
  step %(I want to apply to "#{job_title}" for "#{job_seeker}")
  step %(I find "#{job_seeker}" from my job seekers list and proceed with the application)
  step %(I wait 1 seconds)
  step %(I press "Apply Now")
end

But(/^I cannot find "([^"]*)" from my job seekers list$/) do |job_seeker|
  step %(I cannot select2 "#{job_seeker}" from "jd_apply_job_select")
end

Then(/^I update my profile to not permit job developer to apply a job for me$/) do
  step %(I uncheck "job_seeker_consent")
  step %(I click the "Update Job seeker" button)
  step %(I should see "Jobseeker was updated successfully.")
end

And(/^I accept the confirm dialog/) do
  accept_confirm
end

Then(/^I select (a|another) (license|question)?$/) do |prefix, domain|
  step %(I click the "Add #{domain.capitalize}" link)
  within(:css, "div##{domain}s") do
    first(".select-#{domain}").find(:xpath, 'option[2]').select_option
  end
  if prefix == 'another'
    step %(I click the "Add #{domain.capitalize}" link)
    within(:css, "div##{domain}s") do
      all(".select-#{domain}")[1].find(:xpath, 'option[3]').select_option
    end
  end
end

And(/^I answer (first|another) application question with (Yes|No)/) do |prefix, answer|
  indexes = {
    'Yes': { 'first': 1, 'another': 4 },
    'No': { 'first': 2, 'another': 5 }
  }
  index = indexes[answer.to_sym][prefix.to_sym]
  button = within(:css, 'div#job-apply-modal-id') do
    find('.edit_job').all('.radio-inline')[index]
  end
  button.choose(answer)
end

Then(/^the job "(.*?)" should have (\d+) licenses?$/) do |title, count|
  expect(Job.find_by_title(title).licenses.count).to eq count
end

Given(/^I am creating a Job$/) do
  step %(I press "Post Job" within "all-jobs-pane")
  step %(I fill in "job_title" with "Developer")
  step %(I fill in "job_company_job_id" with "73")
  step %(I fill in "job_description" with "Development")
  fill_in 'job_new_address_attributes_street', with: '3661 West', visible: false
  fill_in 'job_new_address_attributes_city', with: 'J', visible: false
  select('Alabama', from: 'job_new_address_attributes_state', visible: false)
end

When(/^I submit the new job$/) do
  step %(I press "Create")
end

When(/^I fill in job details$/) do
  fill_in 'job_new_address_attributes_street', with: '3661 West', visible: false
  fill_in 'job_new_address_attributes_city', with: 'J', visible: false
  select('Alabama', from: 'job_new_address_attributes_state', visible: false)
end

And(/^I should not see "([^\"]+)" in the search form$/) do |string|
  within(:css, 'div#job_search_form') do
    expect(has_text?(:visible, string)).to be false
  end
end
