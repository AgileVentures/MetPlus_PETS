class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstName
      t.string :lastName
      t.string :email
      t.datetime :lastLogin
      t.string :password, null: false
      t.boolean :administrator,  default: false

      t.timestamps null: false
    end
  end
end
