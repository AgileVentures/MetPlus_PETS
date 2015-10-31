class CreateAgencyPeople < ActiveRecord::Migration
  def change
    create_table :agency_people do |t|
      t.belongs_to :address, index: true, foreign_key: true
      t.belongs_to :agency, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
