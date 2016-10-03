class ChangeCompanyStatusToEnum < ActiveRecord::Migration
  def change
    begin
      if ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        execute "ALTER TABLE companies ALTER status DROP DEFAULT;"
        change_column :comp, :status, 'integer USING CAST(status AS integer)', default: 0, null: false
      else
        change_column :companies, :status, :integer, default: 0, null: false
      end
    rescue NameError
      change_column :companies, :status, :integer, default: 0, null: false
    end
  end
end
