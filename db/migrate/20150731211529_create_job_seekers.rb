class CreateJobSeekers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.actable
    end

    create_table :job_seekers do |t|
      t.integer :year_of_birth
      t.integer :job_seeker_status_id
      t.string :resume_id
      t.timestamps null: false
    end
  end
end
