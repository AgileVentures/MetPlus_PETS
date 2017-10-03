class AddLanguageToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :language, :string
  end
end
