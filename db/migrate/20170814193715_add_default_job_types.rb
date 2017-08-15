class AddDefaultJobTypes < ActiveRecord::Migration
  def change
    JobType.create!({job_type: 'Full Time'})
    JobType.create!({job_type: 'Part Time'})
    JobType.create!({job_type: 'Internship'})
    JobType.create!({job_type: 'Contract'})
    JobType.create!({job_type: 'Salary'})
    JobType.create!({job_type: 'Salary Commission'})
    JobType.create!({job_type: 'Commission Only'})
  end
end
