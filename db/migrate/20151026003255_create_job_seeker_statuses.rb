class CreateJobSeekerStatuses < ActiveRecord::Migration
  def change
    create_table :job_seeker_statuses do |t|
      t.string :value
      t.text :description

      t.timestamps null: false
    end
  end
end
