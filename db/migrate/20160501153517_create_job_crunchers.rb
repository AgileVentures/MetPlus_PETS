class CreateJobCrunchers < ActiveRecord::Migration
  def change
    create_table :job_crunchers do |t|

      t.timestamps null: false
    end
  end
end
