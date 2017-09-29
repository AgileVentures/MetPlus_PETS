class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :abbr
      t.string :title

      t.timestamps null: false
    end

    create_join_table :jobs, :licenses do |t|
      t.index :job_id
      t.index :license_id
    end
  end
end
