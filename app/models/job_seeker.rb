class JobSeeker < ActiveRecord::Base
 	acts_as    :person 
	belongs_to :job_seeker_status
	has_one    :resume 
	has_one	   :address, as: :location
	has_and_belongs_to_many :agency_people 

	validates_presence_of :year_of_birth 

end
