And(/^I (accept|reject|process) "([^"]*)" application for "([^"]*)"$/) do |action, email, job|
  job = Job.find_by(title: job.to_s)
  job_seeker = User.find_by_email(email).actable
  @job_app = JobApplication.find_by(job: job, job_seeker: job_seeker)
  find("#applications-#{@job_app.id} ##{action}_link").click
end

And(/^I should see an "([^"]*)" confirmation$/) do |action|
  expect(page).to have_content("Are you sure you want to #{action} the following application:
Applicant's Name: #{@job_app.job_seeker.full_name(last_name_first: false)}
Job Title: #{@job_app.job.title}
Company Job ID: #{@job_app.job.company_job_id}")
end

And(/^I click the "([^"]*)" confirmation$/) do |action|
  find("a[href='/job_applications/#{@job_app.id}/#{action.downcase}']").click
end

And(/^I\sshould\ssee\s"([^"]*)"\sactive\sapplications\s(for|by)\s
    "([^"]*)"$/x) do |count, created, source|
  if created == 'for'
    job = Job.find_by(title: source.to_s)
    app_ids = JobApplication.select(:id).where(status: 'active', job: job)
  else
    job_seeker = User.find_by_email(source).actable
    app_ids = JobApplication.select(:id).where(status: 'active', job_seeker: job_seeker)
  end
  expect(app_ids.count).to eq count.to_i
end

And(/I\sshould\ssee\s"([^"]*)"\sapplication\sfor\s"([^"]*)"\schanges\sto\s
  (accepted|not_accepted|Processing)$/x) do |email, job, state|
  job = Job.find_by(title: job.to_s)
  job_seeker = User.find_by_email(email).actable
  app = JobApplication.find_by(job_seeker: job_seeker, job: job)
  within("#applications-#{app.id}") { expect(page).to have_content(state) }
end

And(/^other applications for "([^"]*)" change to not accepted$/) do |job|
  job = Job.find_by(title: job.to_s)
  app_ids = JobApplication.select(:id).where.not(status: 'active', job: job)
  app_accepted = JobApplication.select(:id).where(status: 'active', job: job)
  app_ids.each do |app|
    unless app.id == app_accepted.id
      expect(page.find("#applications-#{app.id}"))
        .to have_content('not_accepted')
    end
  end
end

Then(/^I should( not)? see(?: an)? "([^"]*)" link$/) do |not_see, action|
  if not_see
    expect(page).not_to have_css("#{action.downcase}_link", text: action.to_s)
  else
    expect(page).to have_css("#{action.downcase}_link", text: action.to_s)
  end
end

And(/^I should see "([^"]*)" application is listed (first|last)$/) do |email, position|
  job_seeker = User.find_by_email(email).actable
  within(".pagination-div > div > table > tbody > tr:#{position}-child") do
    expect(page).to have_content(job_seeker.first_name.to_s)
  end
end

And(/^I should see "([^"]*)" job changes to status filled/) do |job|
  find('#job-title') { expect(page).to have_content(job) }
  find('#job-status') { expect(page).to have_content('filled') }
end

And(/^I\sshould\ssee\smy\s"([^"]*)"\sapplication\sfor\s"([^"]*)"\swas\s
  "([^"]*)"$/x) do |email, job_title, status|
  job_seeker = User.find_by_email(email).actable
  job = Job.find_by(title: job_title.to_s)
  job_app = JobApplication.find_by(job: job, job_seeker: job_seeker)
  expect(page.find("#applications-#{job_app.id}")).to have_content(status.to_s)
end

And(/^I should see "(?:[^"]*)" show status "([^"]*)"$/) do |status|
  expect(page.find('#job-status')).to have_content(status.to_s)
end

And(/^I return to my "([^"]*)" home page$/) do |email|
  job_seeker = User.find_by_email(email).actable
  role = job_seeker.class.to_s.underscore
  visit "/#{role}s/#{job_seeker.id}/home"
end

And(/^I input "([^"]*)" as the reason for rejection$/) do |reason|
  step %(I fill in "reason_text" with "#{reason}")
end

When(/^I accept "(.*?)" for "(.*?)" with (\d+) opportunit(?:ies|y) left$/) do
  |email, job, positions|
  job = Job.find_by(title: job)
  job.update_attributes(remaining_positions: positions)
  job_seeker = JobSeeker.find_by(email: email)
  job_app = JobApplication.find_by(job_seeker_id: job_seeker.id)
  JobApplications::Hire.new.call(job_app)
end

Then(/^the task to review "(.*?)" application should be closed$/) do |email|
  job_seeker = JobSeeker.find_by(email: email)
  job_app = JobApplication.find_by(job_seeker_id: job_seeker.id)
  task = Task.find_by(job_application: job_app)
  expect(task.status).to eq('Done')
end

Given(/^tasks exist for "(.*?)" and "(.*?)" applications to "(.*?)"$/) do
  |js1, js2, company|
  company = Company.find_by_name(company)
  job_app1 = JobApplication.find_by(job_seeker_id: JobSeeker.find_by(email: js1).id)
  Task.new_review_job_application_task job_app1, company
  job_app2 = JobApplication.find_by(job_seeker_id: JobSeeker.find_by(email: js2).id)
  Task.new_review_job_application_task job_app2, company
end
