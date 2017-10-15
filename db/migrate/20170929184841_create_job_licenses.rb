class CreateJobLicenses < ActiveRecord::Migration
  def change
    create_table :job_licenses do |t|
      t.references :job, index: true, foreign_key: true
      t.references :license, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
