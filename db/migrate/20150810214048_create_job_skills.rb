class CreateJobSkills < ActiveRecord::Migration
  def change
    create_table :job_skills do |t|
      t.references :job
      t.references :skill
      t.boolean :required, default: false, null: false
      t.string :level
      t.integer :min_years
      t.integer :max_years

      t.timestamps null: false
    end
  end
end
