class CreateJobsJobTypesJoinTable < ActiveRecord::Migration
  def change
    create_join_table :jobs, :job_types do |t|
      t.index :job_id
      t.index :job_type_id
    end
  end
end
