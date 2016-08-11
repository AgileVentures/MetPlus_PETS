class RemoveResumeFromJobSeekers < ActiveRecord::Migration
  def change
    remove_column :job_seekers, :resume, :string
  end
end
