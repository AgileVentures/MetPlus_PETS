class AgencyPeopleJobSeekersJoinTable < ActiveRecord::Migration
  	def change
    	create_table :seekers_agency_people, id: false do |t|
    		t.integer :agency_person_id 
    		t.integer :job_seeker_id 
    end
   	  add_index :seekers_agency_people, [:agency_person_id, :job_seeker_id], :name => "seekersagencypeople"
  end
end
