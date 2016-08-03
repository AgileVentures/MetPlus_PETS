class DropSkillLevels < ActiveRecord::Migration
  def change
  	drop_table :skill_levels
  end
end
