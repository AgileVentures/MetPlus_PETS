class AddBranchToAgencyPeople < ActiveRecord::Migration
  def up
    change_table :agency_people do |t|
      t.references :branch, index: true, foreign_key: true
      t.remove     :address_id
    end
  end
  def down
    change_table :agency_people do |t|
      t.remove :branch_id
      t.references :address, index: true, foreign_key: true
    end
  end
end
