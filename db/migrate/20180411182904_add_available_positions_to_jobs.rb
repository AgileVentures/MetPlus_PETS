class AddAvailablePositionsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :available_positions, :integer, default: 1
  end
end
