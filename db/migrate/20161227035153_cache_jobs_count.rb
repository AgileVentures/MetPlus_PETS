class CacheJobsCount < ActiveRecord::Migration
  def change
    execute "UPDATE skills SET jobs_count=(SELECT count(*) FROM job_skills WHERE job_skills.skill_id=skills.id)"
  end
end
