Given(/^the following jobseeker exist:$/) do |table|
  table.hashes.each do |hash|
       
    
    jobseeker = hash.delete 'jobseeker'
    hash['actable_type'] = 'JobSeeker'
    hash['password_confirmation'] = hash['password']
    hash['confirmed_at'] = Time.now
        
    jobseeker = JobSeeker.new(hash)
    jobseeker.save
  end
end


Given(/^I am on the Jobseeker Registration page$/) do
  #pending # express the regexp above with the code you wish you had
    visit "/job_seekers/new"
end







