class AddFulltimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :fulltime, :boolean, default: false  
  end
end