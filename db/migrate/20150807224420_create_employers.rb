class CreateEmployers < ActiveRecord::Migration
  def change
    create_table :employers do |t|
      t.integer :company_id
      t.string :phone

      t.timestamps null: false
    end
  end
end
