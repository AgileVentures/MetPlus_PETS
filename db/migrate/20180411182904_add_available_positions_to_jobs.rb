class AddAvailablePositionsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :available_positions, :integer
  end
end
