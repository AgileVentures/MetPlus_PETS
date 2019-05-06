class ChangeCompanyPersonStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ApplicationRecord.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "ALTER TABLE company_people ALTER status DROP DEFAULT"
        execute "UPDATE company_people SET status='0' where status='Pending'"
        execute "UPDATE company_people SET status='1' where status='Invited'"
        execute "UPDATE company_people SET status='2' where status='Active'"
        execute "UPDATE company_people SET status='3' where status='Inactive'"
        execute "UPDATE company_people SET status='4' where status='Denied'"
        execute "ALTER TABLE company_people ALTER status TYPE integer USING status::integer"
      else
        change_column :company_people, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :company_people, :status, :integer, default: 0, null: false
    end
  end
end
