class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations do |t|
      t.string :level, null_allowed: false
      t.integer :rank, null_allowed: false

      t.timestamps null: false
    end
  end
end
