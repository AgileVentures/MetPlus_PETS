require 'job_seeker_status'
class CreateJobSeekerStatuses < ActiveRecord::Migration
  def change
    create_table :job_seeker_statuses do |t|
      t.string :value
      t.string :description

      t.timestamps null: false
    end
    JobSeekerStatus.new(:value => 'Active Search', :description => 'Actively searching for job').save!
    JobSeekerStatus.new(:value => 'Just Looking', :description => 'Currently employed, but looking for opportunities').save!
    JobSeekerStatus.new(:value => 'Not looking', :description => 'Not looking for a job').save!
  end
end
