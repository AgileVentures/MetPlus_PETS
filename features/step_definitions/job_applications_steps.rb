And(/^I click "([^"]*)" link to job applications index page$/) do |job_title|
	job = Job.find_by(title: "#{job_title}")
	find("a[href='/jobs/#{job.id}/applications']").click 
end

And(/^I click "([^"]*)" link to job show page$/) do |job_title|
	job = Job.find_by(title: "#{job_title}")
	find("#applications-my-applied a[href='/jobs/#{job.id}']").click
end

And(/^I click "([^"]*)" link to "([^"]*)'s" job application show page$/) do |email, js_name|
	job_seeker = User.find_by_email(email).actable
	@job_app = JobApplication.find_by(job_seeker: job_seeker)
	find("a[href='/job_applications/#{@job_app.id}']").click
end

And(/^I accept "([^"]*)" application$/) do |email|
	job_seeker = User.find_by_email(email).actable
	@job_app = JobApplication.find_by(job_seeker: job_seeker)
	find("#applications-#{@job_app.id} a.accept_link").click
end

And(/^I reject "([^"]*)" application$/) do |email|
	job_seeker = User.find_by_email(email).actable
	@job_app = JobApplication.find_by(job_seeker: job_seeker)
	find("#applications-#{@job_app.id} a.reject_link").click
end

And(/^I should see an "([^"]*)" confirmation$/) do |action|
	expect(page).to have_content("Are you sure you want 
 		         to #{action} the following application: 
 		         		 applicant's name: #{@job_app.job_seeker.full_name(last_name_first: false)}
                 job title:  #{@job_app.job.title}
                 company job id: #{@job_app.job.company_job_id}")
end

And(/^I click the "([^"]*)" confirmation$/) do |action|
	find("a[href='/job_applications/#{@job_app.id}/#{action.downcase}']").click
end 

And(/^I should see "([^"]*)" active applications for the job$/) do |count|
	@app_ids = JobApplication.select(:id).where(status: 'active')
	expect(@app_ids.count).to eq count.to_i
end

And(/^I should see "([^"]*)" application changes to accepted$/) do |email|
	job_seeker = User.find_by_email(email).actable
	@app_accepted = JobApplication.find_by(job_seeker: job_seeker)
	within("#applications-#{@app_accepted.id}") { expect(page).to have_content("accepted") }
end

And(/^I should see "([^"]*)" application changes to not_accepted$/) do |email|
	job_seeker = User.find_by_email(email).actable
	@app_rejected = JobApplication.find_by(job_seeker: job_seeker)
	within("#applications-#{@app_rejected.id}") { expect(page).to have_content("not_accepted") }
end

# this step can only be used in a scenario that includes steps line:35 and line:42
# which define @app_ids, @app_accepted
And(/^other applications change to not accepted$/) do 
	@app_ids.each do |app|
		expect(page.find("#applications-#{app.id}")).
		to have_content("not_accepted") unless app.id == @app_accepted.id
	end
end

Then(/^I should( not)? see(?: an)? "([^"]*)" link$/) do |not_see, action|
	if not_see
		expect(page).not_to have_css("a.#{action.downcase}_link", text: "#{action}")
	else
		expect(page).to have_css("a.#{action.downcase}_link", text: "#{action}")
	end
end

And(/^I should see "([^"]*)" application is listed first$/) do |email|
	job_seeker = User.find_by_email(email).actable
	job_app = JobApplication.find_by(job_seeker: job_seeker)
	within(".pagination-div > table > tbody > tr:first-child") { expect(page).to have_content("#{job_seeker.first_name}") }
end

And(/^I should see "([^"]*)" application is listed last$/) do |email|
	job_seeker = User.find_by_email(email).actable
	job_app = JobApplication.find_by(job_seeker: job_seeker)
	within(".pagination-div > table > tbody > tr:last-child") { expect(page).to have_content("#{job_seeker.first_name}") }
end

And(/^I should see "([^"]*)" job changes to status filled/) do |job_title|
	find("#job-status") { expect(page).to have_content("filled") }
end

And(/^I should see my application for "([^"]*)" show status "([^"]*)"$/) do |job_title, status|
	job = Job.find_by(title: "#{job_title}")
	job_app = JobApplication.find_by(job: job)
	expect(page.find("#applications-#{job_app.id}")).to have_content("#{status}")
end

And(/^I am returned to "([^"]*)" job application index page$/) do |job_title|
	expect(page.find("#job-title")).to have_content("#{job_title}")
end

And(/^I should see "(?:[^"]*)" show status "([^"]*)"$/) do |status|
	expect(page.find("#job-status")).to have_content("#{status}")
end 

And(/^I return to my "([^"]*)" home page$/) do |email|
	job_seeker = User.find_by_email(email).actable
	role = job_seeker.class.to_s.underscore
	visit "/#{role}s/#{job_seeker.id}/home"
end

And(/^I input "([^"]*)" as the reason for rejection$/) do |reason|
  step %{I fill in "reason_text" with "#{reason}"}
end

	  
