class CreateJobCategories < ActiveRecord::Migration
  def change
    create_table :job_categories do |t|
      t.string :name
      t.string :description
      t.belongs_to :jobs, index: true, foreign_key: true
      t.belongs_to :skills, index: true, foreign_key: true

      t.belongs_to :job_speciliaties, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end



