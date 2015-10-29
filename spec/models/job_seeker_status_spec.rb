require 'rails_helper'

describe JobSeekerStatus, type: :model do
	
	        FactoryGirl.create(:job_seeker_status, value: 'Unemployedlooking',  
	        	:description => "A jobseeker Without any work and looking for a job.")
            FactoryGirl.create(:job_seeker_status, value: 'Employedlooking',    
            	:description => "A jobseeker with a job and looking for a job.")
            FactoryGirl.create(:job_seeker_status, value: 'Employednotlooking', 
            	:description => "A jobseeker with a job and not looking for a job for now." )

   
	it{is_expected.to have_db_column :description} 
	it{is_expected.to have_db_column :value} 


	it {is_expected.to validate_presence_of :description} 
	it { is_expected.to validate_presence_of :value }
	it { is_expected.to have_many :jobseekers }
	
	

	it{ is_expected.to validate_length_of(:description).is_at_most(255)}
    it{ is_expected.to validate_length_of(:description).is_at_least(10)}
     
    describe JobSeekerStatus.select(:value).map(&:value) do 
    	it{should include('Unemployedlooking', 'Employedlooking', 'Employednotlooking')}
    end

end

