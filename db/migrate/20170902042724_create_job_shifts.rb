class CreateJobShifts < ActiveRecord::Migration
  def change
    create_table :job_shifts do |t|
      t.string :shift

      t.timestamps null: false
    end
  end
end
