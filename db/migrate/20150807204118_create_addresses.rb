class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :full_address
      t.integer :zipcode
      t.string :state
      t.string :city

      t.timestamps null: false
    end
  end
end
