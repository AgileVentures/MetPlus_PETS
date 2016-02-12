Then(/^I should verify the change of title "(.*?)", shift "(.*?)" and jobId "(.*?)"$/) do |title, shift, jobId|
  # pending # express the regexp above with the code you wish you had
  job = Job.find_by_title(title)
  expect(job.shift).to eql shift
  expect(job.jobId).to eql jobId 

end


