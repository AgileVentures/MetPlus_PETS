class CreateJobSeekers < ActiveRecord::Migration
  def change
    create_table :job_seekers do |t|
      t.string :year_of_birth
      t.belongs_to :job_seeker_status, index: true, foreign_key: true
      t.string :resume

      t.timestamps null: false
    end
  end
end
