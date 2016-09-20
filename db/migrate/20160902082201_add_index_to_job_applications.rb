class AddIndexToJobApplications < ActiveRecord::Migration
  def change
  	add_index(:job_applications, [:job_id, :job_seeker_id], unique: true)
  end
end
