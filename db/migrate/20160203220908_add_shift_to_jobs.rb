class AddShiftToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :shift, :string
  end
end
