class RemoveFulltimeFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :fulltime
  end
end
