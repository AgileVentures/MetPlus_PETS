class ChangeAgencyPersonStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "UPDATE TABLE agency_people SET status='0' where status='Invited'"
        execute "UPDATE TABLE agency_people SET status='1' where status='Active'"
        execute "UPDATE TABLE agency_people SET status='2' where status='Inactive'"

        change_column :agency_people, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
      else
        change_column :agency_people, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :agency_people, :status, :integer, default: 0, null: false
    end
  end
end
