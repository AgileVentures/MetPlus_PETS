class AddLanguageProficiencyToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :language_proficiency, :text, null: true
  end
end
