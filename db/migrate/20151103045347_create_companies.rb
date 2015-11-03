class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|

      t.string :name
      t.string :ein
      t.string :phone
      t.string :email
      t.string :website

      t.timestamps null: false
    end
  end
end
