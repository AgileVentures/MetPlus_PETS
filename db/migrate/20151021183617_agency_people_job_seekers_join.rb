class AgencyPeopleJobSeekersJoin < ActiveRecord::Migration
  def change
    create_table :agencies_seekers, id: false do |t|
    	t.integer :agency_person_id 
    	t.integer :job_seeker_id 
    end
    add_index :agencies_seekers, [:agency_person_id, :job_seeker_id]
  end
end
