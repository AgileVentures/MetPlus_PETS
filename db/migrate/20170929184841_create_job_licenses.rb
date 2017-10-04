class CreateJobLicenses < ActiveRecord::Migration
  def change
    create_table :job_licenses do |t|
      t.references :job
      t.references :license

      t.timestamps null: false
    end
  end
end
