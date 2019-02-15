class ChangeAgencyPersonStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ApplicationRecord.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "ALTER TABLE agency_people ALTER status DROP DEFAULT"
        execute "UPDATE agency_people SET status='0' where status='Invited'"
        execute "UPDATE agency_people SET status='1' where status='Active'"
        execute "UPDATE agency_people SET status='2' where status='Inactive'"
        execute "ALTER TABLE agency_people ALTER status TYPE integer USING status::integer"
      else
        change_column :agency_people, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :agency_people, :status, :integer, default: 0, null: false
    end
  end
end
