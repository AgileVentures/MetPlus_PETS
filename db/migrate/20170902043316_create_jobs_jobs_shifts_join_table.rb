class CreateJobsJobsShiftsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :jobs, :job_shifts do |t|
      t.index :job_id
      t.index :job_shift_id
    end
  end
end
