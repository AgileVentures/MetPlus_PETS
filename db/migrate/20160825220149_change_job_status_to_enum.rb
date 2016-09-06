class ChangeJobStatusToEnum < ActiveRecord::Migration
  def change
    change_column :jobs, :status, :integer, default: 0, null: false
  end
end
