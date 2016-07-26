class RemoveSkillLevelFromJobSkills < ActiveRecord::Migration
  def change
  	remove_reference :job_skills, :skill_level, index: true, foreign_key: true
  end
end
