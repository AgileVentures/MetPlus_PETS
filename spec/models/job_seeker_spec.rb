require 'rails_helper'

describe JobSeeker, type: :model do

	let(:salem){FactoryGirl.build(:job_seeker, :year_of_birth => "983",  :resume => "myresum",
		:first_name => "salem", :last_name=> "Abdu", :phone => "619-232-2345")}
	let(:sam) {FactoryGirl.build(:job_seeker, :year_of_birth => "1915",  :resume=> "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "619-232-2345")}
	let(:fatuma){FactoryGirl.build(:job_seeker, :year_of_birth => "1911",:resume=> "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "619-232-2345")}
	let(:ali) {FactoryGirl.build(:job_seeker, :year_of_birth => "1983",  :resume=> "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "619-232-2345")}
	let(:omar) {FactoryGirl.build(:job_seeker, :year_of_birth => "1192", :resume => "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "619-232-2345")}
	let(:john) {FactoryGirl.build(:job_seeker, :year_of_birth => "2016", :resume => "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "(619)-232-2345")}

	let(:james) {FactoryGirl.build(:job_seeker, :year_of_birth => "2016", :resume => "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "(61)-232-2345")} 
	let(:kay) {FactoryGirl.build(:job_seeker, :year_of_birth => "2016", :resume => "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "(619)-22-2345")} 
	let(:jay) {FactoryGirl.build(:job_seeker, :year_of_birth => "2016", :resume => "resume",
		:first_name => "salem", :last_name=> "Abdu", :phone => "(619)-232-234")}
	
    
    it "should have table column names: year_of_birth and job_seeker_status_id" do
		is_expected.to have_db_column :year_of_birth
		is_expected.to have_db_column :job_seeker_status_id  
		is_expected.to have_db_column :resume
	end

	context "should be invalide phone numbers" do 
		it {expect(james).to_not be_valid}
		it {expect(kay).to_not be_valid}
		it {expect(jay).to_not be_valid}
	end

	it "should not be blank" do 
		is_expected.to validate_presence_of(:year_of_birth) 
	end

	it "has many and belongs to agency people" do
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
		it {expect(john).to_not be_valid}
	end

	describe "#acting_as?" do
	    it "returns true for supermodel class and name" do
	      expect(JobSeeker.acting_as? :user).to be true
	      expect(JobSeeker.acting_as? User).to  be true
	    end

	    it "returns false for anything other than supermodel" do
	      expect(JobSeeker.acting_as? :model).to be false
	      expect(JobSeeker.acting_as? String).to be false
	    end
 	end


end
