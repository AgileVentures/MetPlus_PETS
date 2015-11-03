class CreateJoinTableAgencyPeopleAgencyRole < ActiveRecord::Migration
  def change
    create_join_table :agency_people, :agency_roles do |t|
      # t.index [:agency_person_id, :agency_role_id]
      # t.index [:agency_role_id, :agency_person_id]
    end
  end
end
