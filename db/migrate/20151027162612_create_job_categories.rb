class CreateJobCategories < ActiveRecord::Migration
  def change
    create_table :job_categories do |t|
      t.string :name
      t.string :description
      t.references :skills, index: true, foreign_key: true 
      t.references :jobs, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end



