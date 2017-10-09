class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :abbr
      t.string :title

      t.timestamps null: false
    end
  end
end
