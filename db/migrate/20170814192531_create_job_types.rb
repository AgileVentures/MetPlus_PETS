class CreateJobTypes < ActiveRecord::Migration
  def change
    create_table :job_types do |t|
      t.string :job_type

      t.timestamps null: false
    end
  end
end
