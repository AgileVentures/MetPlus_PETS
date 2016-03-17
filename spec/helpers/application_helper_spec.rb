require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context 'single_line_address method' do
    it 'returns string for address' do
      address = FactoryGirl.build(:address)
      expect(single_line_address(address)).
          to eq "#{address.street}, #{address.city}, #{address.zipcode}"
    end
    it 'return no-address for nil' do
      expect(single_line_address(nil)).
          to eq 'No Address'
    end
  end

 context '#correct_user_type' do 
     
   it "should return company person instance/object" do 
     company_person = FactoryGirl.create(:company_person)
     current_user = company_person.acting_as
     expect(company_person).to eql(correct_user_type(current_user))
   end

   it "should return user instance/object" do 
       current_user = FactoryGirl.create(:user) 
       expect(current_user).to eql(correct_user_type(current_user))
    end


    it "should return jobseeker instance/object" do
       job_seeker = FactoryGirl.create(:job_seeker)
       current_user = job_seeker.acting_as  
       expect(job_seeker).to eql(correct_user_type(current_user))
    end

    it "should return agency person instance/object" do 
       agency_person = FactoryGirl.create(:agency_person)
       current_user = agency_person.acting_as
       expect(agency_person).to eql(correct_user_type(current_user))
    end

 end

  context '#full_title' do 
    
   it "base title" do 
     expect(helper.full_title()).to eq("MetPlus")
   end

   it "show page title" do 
       expect(helper.full_title("Ruby on Rails")).to eq("Ruby on Rails | MetPlus")
   end

  end

end
