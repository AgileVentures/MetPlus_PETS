class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.datetime :last_login
      t.string :password
      t.string :password_digest
      t.boolean :administrator,  default: false
      t.boolean :email_activation, default: false

      t.timestamps null: false
    end
  end
end
