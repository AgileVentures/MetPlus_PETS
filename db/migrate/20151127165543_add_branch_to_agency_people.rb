class AddBranchToAgencyPeople < ActiveRecord::Migration
  change_table :agency_people do |t|
    t.references :branch, index: true, foreign_key: true
    t.remove     :address_id
  end
end
