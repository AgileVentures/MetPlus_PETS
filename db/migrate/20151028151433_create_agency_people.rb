class CreateAgencyPeople < ActiveRecord::Migration
  def change
    create_table :agency_people do |t|
      t.references :agency, index: true, foreign_key: true
      t.references :address, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
