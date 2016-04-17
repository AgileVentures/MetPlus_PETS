class CreateJobApplications < ActiveRecord::Migration
  def change
    create_table :job_applications do |t|
      t.belongs_to :job_seeker, index: true, foreign_key: true
      t.belongs_to :job, index: true, foreign_key: true
      t.integer    :status, default: 0, null: false

      t.timestamps null: false
    end
  end
end
