class ChangeJobStatusToEnum < ActiveRecord::Migration
  def change
    execute "ALTER TABLE jobs ALTER status DROP DEFAULT;"
    change_column :jobs, :status,  'integer USING CAST(status AS integer)', default: 0, null: false
  end
end
