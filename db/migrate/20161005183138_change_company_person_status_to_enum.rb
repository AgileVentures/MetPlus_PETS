class ChangeCompanyPersonStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "UPDATE TABLE company_people SET status='0' where status='Pending'"
        execute "UPDATE TABLE company_people SET status='1' where status='Invited'"
        execute "UPDATE TABLE company_people SET status='2' where status='Active'"
        execute "UPDATE TABLE company_people SET status='3' where status='Inactive'"
        execute "UPDATE TABLE company_people SET status='4' where status='Denied'"

        change_column :company_people, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
      else
        change_column :company_people, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :company_people, :status, :integer, default: 0, null: false
    end
  end
end
