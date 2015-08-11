class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :job_identifier
      t.integer :employer_id
      t.integer :company_id
      t.string :title
      t.text :description
      t.references :location

      t.timestamps null: false
    end
  end
end
