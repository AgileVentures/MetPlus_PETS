Then(/^I should verify the change of title "(.*?)", shift "(.*?)" and jobId "(.*?)"$/) do |title, shift, jobId|
	
	@job = Job.find_by_title(title)
	expect(@job.shift).to eql shift
	expect(@job.company_job_id).to eql jobId 

end

Then(/^I should a popup with the job information$/) do
 	expect(page).to have_content("Are you sure you want 
 	       to delete the following job: 
 	       job title:  #{@job.title}
 	       job id: #{@job.company_job_id}")
end


