require 'rails_helper'

describe JobSeeker, type: :model do

	let(:salem){FactoryGirl.build(:job_seeker, :year_of_birth => "0/12/1983")}
	let(:sam) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/12/1983")}
	let(:fatuma){FactoryGirl.build(:job_seeker, :year_of_birth => "12/2/1978")}
	let(:ali) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/01/1983")}
	let(:omar) {FactoryGirl.build(:job_seeker, :year_of_birth => "12/12/192")}
	
    
    #note: I didn't bother to test :id here, you should know the reason.
    it "should have table column names: year_of_birth and job_seeker_status_id" do
		is_expected.to have_db_column :year_of_birth
		is_expected.to have_db_column :job_seeker_status_id  
	end

	it "should not be blank" do 
		is_expected.to validate_presence_of(:year_of_birth) 
	end

	it "has many and belongs to agency people"do
		pending "need to create joint table agency_people<>job_seeker"
		is_expected.to have_and_belong_to_many :agency_people
	end

	context "with valid attributes" do 
		it {expect(sam).to be_valid  }
		it {expect(ali).to be_valid  }
	end

	context "with invalide attributes" do
		it {expect(salem).to_not be_valid}
		it {expect(fatuma).to_not be_valid}
		it {expect(omar).to_not be_valid}
	end

	it "is belongs to jobseeeker status,  with valid attributes" do 
		sam.save
		@job_seeker_status = JobSeekerStatus.create!(:value => "Employed not looking for job",
		 :description => "A"*244)
		# byebug
    	sam.job_seeker_status = @job_seeker_status
		is_expected.to belong_to :job_seeker_status
	    expect(sam.job_seeker_status).not_to be_nil 
	    
	end

	it "is belongs to jobseeeker status with,  invalid attributes" do 
		ali.save 
		@job_seeker_status = JobSeekerStatus.new(:value => "", :description => "A"*244)
		@job_seeker_status.save 
    	ali.job_seeker_status = @job_seeker_status
		is_expected.to belong_to :job_seeker_status
	    expect(ali.job_seeker_status.id).to  be_nil 
	end

	#ONCE THE USER MODEL COMPLETE, UNCOMMENT THIS PART.
	# describe "#acting_as?" do
	#     it "returns true for supermodel class and name" do
	#       expect(JobSeeker.acting_as? :user).to be true
	#       expect(JobSeeker.acting_as? User).to  be true
	#     end

	#     it "returns false for anything other than supermodel" do
	#       expect(JobSeeker.acting_as? :model).to be false
	#       expect(JobSeeker.acting_as? String).to be false
	#     end
 # 	end

end
