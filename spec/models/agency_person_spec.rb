require 'rails_helper'

describe AgencyPerson, type: :model do
 
 	 describe 'Database schema' do
	    it { is_expected.to have_db_column :agency_id  }
	    it { is_expected.to have_db_column :address_id }
	end
     
	xit "remove xit part after merging with Agency model" do 
		it{ is_expected.to belong_to(:agency) } 
	end

    xit "remove xit part after merging or creating JobSpeciality model" do 
		it{ is_expected.to have_many :job_specialities}
	end

	xit "remove xit part after merging JobSeeker model" do 
		it{ is_expected.to have_and_belong_to_many(:job_seekers) }
	end

	xit "remove xit part after mergin or creating AgencyRole model " do 
		it{ is_expected.to have_and_belong_to_many(:agency_roles) }
	end

	xit "remove xit part after mergin or creating JobCategory model " do 
		it{ is_expected.to have_many(:job_categories) }
	end

	it{ is_expected.to belong_to(:address) }


	context "#acting_as?" do
	    it "returns true for supermodel class and name" do
	      expect(AgencyPerson.acting_as? :user).to be true
	      expect(AgencyPerson.acting_as? User).to  be true
	    end

	    it "returns false for anything other than supermodel" do
	      expect(AgencyPerson.acting_as? :model).to be false
	      expect(AgencyPerson.acting_as? String).to be false
	    end
	end

end
