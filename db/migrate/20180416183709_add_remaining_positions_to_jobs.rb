class AddRemainingPositionsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :remaining_positions, :integer
  end
end
