class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.references :agency, index: true, foreign_key: true
      t.references :address, index: true, foreign_key: true
      t.string :code, limit: 8

      t.timestamps null: false
    end
  end
end
