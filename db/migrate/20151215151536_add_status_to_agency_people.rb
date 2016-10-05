class AddStatusToAgencyPeople < ActiveRecord::Migration
  def change
    add_column :agency_people, :status, :string, default: 'Active'
  end
end
