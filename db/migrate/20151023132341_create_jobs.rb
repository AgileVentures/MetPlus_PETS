class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :description
      t.references :company, index: true, foreign_key: true
      t.references :company_person, index: true, foreign_key: true
      t.references :job_category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
