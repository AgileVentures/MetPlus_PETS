class AddAdditionalSkillsToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :additional_skills, :text
  end
end
