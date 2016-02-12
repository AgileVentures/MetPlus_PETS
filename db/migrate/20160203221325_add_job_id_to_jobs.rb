class AddJobIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :jobId, :string
  end
end
