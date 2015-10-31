class CreateJoinTableJobCategorySkills < ActiveRecord::Migration
  def change
    create_join_table :job_categories, :skills do |t|
      # t.index [:job_category_id, :skill_id]
      # t.index [:skill_id, :job_category_id]
    end
  end
end
