class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :website
      t.string :phone
      t.string :email

      t.timestamps null: false
    end
  end
end
