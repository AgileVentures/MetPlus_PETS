require 'rails_helper'

describe JobSeeker, type: :model do
	let(:salem){FactoryGirl.build(:job_seeker, :year_of_birth => "0/12/1983")}
	let(:sam) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/12/1983")}
	let(:fatuma){FactoryGirl.build(:job_seeker, :year_of_birth => "12/2/1978")}
	let(:ali) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/01/1983")}
	let(:omar) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/12/192")}
		
	it "should not be blank" do 
		is_expected.to validate_presence_of(:year_of_birth) 
	end

	it "is belongs to jobseeeker status" do 
		pending "need to create jobseeker model"
	    is_expected.to belong_to :job_seeker_status 
	end

	it "has many and belongs to agency people"do
		pending "need to create joint table agency_people<>job_seeker"
		is_expected.to have_and_belong_to_many :agency_people
	end

	context "with valid attributes" do 
		it { expect(sam).to be_valid }
		it {expect(ali).to be_valid  }
	end

	context "with invalide attributes" do
		it {expect(salem).to_not be_valid}
		it {expect(fatuma).to_not be_valid}
		it {expect(omar).to_not be_valid}
	end
end
