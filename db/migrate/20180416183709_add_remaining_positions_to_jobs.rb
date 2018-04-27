class AddRemainingPositionsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :remaining_positions, :integer, default: 1
  end
end
