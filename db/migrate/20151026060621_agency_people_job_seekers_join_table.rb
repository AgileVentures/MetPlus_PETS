class AgencyPeopleJobSeekersJoinTable < ActiveRecord::Migration
  	def change
    	create_table :agency_people_job_seekers, id: false do |t|
    		t.integer :agency_person_id 
    		t.integer :job_seeker_id 
    end
   	  add_index :agency_people_job_seekers, [:agency_person_id, :job_seeker_id], :name => "seekers_agency_people"
  end
end
