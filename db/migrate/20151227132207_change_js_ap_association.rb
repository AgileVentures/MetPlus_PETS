class ChangeJsApAssociation < ActiveRecord::Migration
  def change
    remove_index :seekers_agency_people, name: :seekersagencypeople,
                column: [:agency_person_id, :job_seeker_id]
    rename_table :seekers_agency_people, :agency_relations
    add_column :agency_relations, :id, :primary_key
    add_reference :agency_relations, :agency_role,
                    index: true, foreign_key: true

    add_index :agency_relations, :agency_person_id
    add_index :agency_relations, :job_seeker_id
  end
end
