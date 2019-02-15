class ChangeJobStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ApplicationRecord.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "ALTER TABLE jobs ALTER status DROP DEFAULT;"
        change_column :jobs, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
      else
        change_column :jobs, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :jobs, :status, :integer, default: 0, null: false
    end
  end
end
