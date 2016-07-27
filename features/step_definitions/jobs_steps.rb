Then(/^I should verify the change of title "(.*?)", shift "(.*?)" and jobId "(.*?)"$/) do |title, shift, jobId|
	
	@job = Job.find_by_title(title)
	expect(@job.shift).to eql shift
	expect(@job.company_job_id).to eql jobId 

end

Then(/^I should see a popup with the following job information$/) do
 	expect(page).to have_content("Are you sure you want 
 		         to delete the following job: 
                 job title:  #{@job.title}
                 job id: #{@job.company_job_id}")
end 

Given(/^the Widgets, Inc\. company name with address exist in the record$/) do
	FactoryGirl.create(:company)
end

Then(/^I (?:visit|return to) the jobs page$/) do
	@job = nil
	visit jobs_path
end

# I should see "Revoked" span corresponds to "hr assistant"
# I should see "revoke" button corresponds to "hr manager"
Then(/^I should( not)? see "([^"]*)"( \w*) corresponds to "([^"]*)"$/) do |negate, tag_name, tag, job_title|
	@job ||= Job.find_by(title: job_title)
	if negate
		expect(page).not_to have_css("#job-#{@job.id}#{tag}", text: tag_name)
	else
		expect(page).to have_css("#job-#{@job.id}#{tag}", text: tag_name)
	end
end

Then(/^I should see a "([^"]*)" confirmation$/) do |action|
	expect(page).to have_content("Are you sure you want 
 		         to #{action} the following job: 
                 job title:  #{@job.title}
                 job id: #{@job.company_job_id}")
end 

Then(/^I click the "revoke" button belongs to "hr manager"/) do
	job = Job.find_by(title: "hr manager")
	step %(I click the third "revoke" button)
	byebug
	find("#job-#{job.id} > button[data-target='#revokeModal']").click 
end

Then(/^I click the "([^"]*)" confirmation corresponds to "([^"]*)"$/) do |tag_name, job_title|
	@job ||= Job.find_by(title: job_title)
	step %{I click the "##{tag_name.downcase}-job-#{@job.id}" link}
	# find("##{tag_name.downcase}-job-#{@job.id}").click
end

Then(/^I click the "([^"]*)" link to job show page$/) do |job_title|
	@job ||= Job.find_by(title: job_title)
	find("a[href='/jobs/#{@job.id}']").click
end

Then(/^I should( not)? see "Revoke" link on the page$/) do |negate|
	if negate
		expect(page).not_to have_css('a[data-target="#revokeModal"]', text: 'Revoke')
	else
		expect(page).to have_css('a[data-target="#revokeModal"]', text: 'Revoke')
	end
end


