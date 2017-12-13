class AddColumnJobApplicationToJobs < ActiveRecord::Migration
  def change
    add_column :tasks, :job_application_id, :integer
    Task.all do |task|
      task.job_application_id = task.job.job_applications.first.id
      task.save
    end
    add_foreign_key :tasks, :job_applications
  end
end
