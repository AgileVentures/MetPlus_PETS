require 'rails_helper'

describe JobSeekerStatus, type: :model do
	 #note description should in range [10 255) 
	 let(:salem){FactoryGirl.build(:job_seeker_status, 
	 	      :description => "R"*254, :value => "Unemployed actively looking for job")}
	 let(:sam){FactoryGirl.build(:job_seeker_status, 
	 	      :description => "RoR"*10, :value => "Employed not looking for job")}
	 let(:ali){FactoryGirl.build(:job_seeker_status, 
	 	      :description => "RoR"*2, :value => "Employed actively looking for job")}
	 let(:sam){FactoryGirl.build(:job_seeker_status, 
	 	      :description => "RoR"*10, :value => "Employed not looking for job")}
	 let(:fatuma){FactoryGirl.build(:job_seeker_status, 
	 	      :description => "RoR"*10, :value => "")}

     #note :id not test, since it is obvious 
	it "should have table column names: description and value" do
		is_expected.to have_db_column :description
		is_expected.to have_db_column :value 
	end
	it "should not be blank" do 
		is_expected.to validate_presence_of(:description)
		is_expected.to validate_presence_of(:value) 
	end

	it "has many jobseekers" do 
	    is_expected.to have_many :jobseekers 
	end

	context "with valid attributes" do 
		it { expect(salem).to be_valid }
		it {expect(sam).to be_valid  }
	end

	context "with invalide attributes" do
		it {expect(ali).to_not be_valid}
		it {expect(fatuma).to_not be_valid}
	end
end

