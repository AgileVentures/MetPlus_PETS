class AddJobsCountToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :jobs_count, :integer, default: 0, null: false
  end
end
