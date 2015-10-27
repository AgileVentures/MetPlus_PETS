require 'rails_helper'

describe JobSeekerStatus, type: :model do
   
	it{is_expected.to have_db_column :description} 
	it{is_expected.to have_db_column :value} 


	it{is_expected.to validate_presence_of :description} 
	it { is_expected.to validate_presence_of :value }

	it "uncomment the pending when JS model created", pending: true do 
		is_expected.to have_many :jobseekers 
	end
	

	it{ is_expected.to validate_length_of(:description).is_at_most(255)}
    it{ is_expected.to validate_length_of(:description).is_at_least(10)}
	
end

