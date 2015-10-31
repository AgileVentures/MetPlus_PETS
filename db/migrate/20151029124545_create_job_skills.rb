class CreateJobSkills < ActiveRecord::Migration
  def change
    create_table :job_skills do |t|
      t.references :job, index: true, foreign_key: true
      t.references :skill, index: true, foreign_key: true
      t.references :skill_level, index: true, foreign_key: true
      t.boolean :required, default: false
      t.integer :min_years
      t.integer :max_years

      t.timestamps null: false
    end
  end
end
