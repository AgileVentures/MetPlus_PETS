class ChangeCompanyStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ApplicationRecord.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "ALTER TABLE companies ALTER status DROP DEFAULT"
        execute "UPDATE companies SET status='0' where status='Pending Registration'"
        execute "UPDATE companies SET status='1' where status='Active'"
        execute "UPDATE companies SET status='2' where status='Inactive'"
        execute "UPDATE companies SET status='3' where status='Registration Denied'"
        execute "ALTER TABLE companies ALTER status TYPE integer USING status::integer"
      else
        change_column :companies, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :companies, :status, :integer, default: 0, null: false
    end
  end
end
