class CreateAgencyRoles < ActiveRecord::Migration
  def change
    create_table :agency_roles do |t|
      t.string :role

      t.timestamps null: false
    end
  end
end
