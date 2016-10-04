class ChangeCompanyStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "UPDATE TABLE companies SET status='0' where status='Pending Registration'"
        execute "UPDATE TABLE companies SET status='1' where status='Active'"
        execute "UPDATE TABLE companies SET status='2' where status='Inactive'"
        execute "UPDATE TABLE companies SET status='3' where status='Registration Denied'"

        change_column :companies, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
      else
        change_column :companies, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :companies, :status, :integer, default: 0, null: false
    end
  end
end
