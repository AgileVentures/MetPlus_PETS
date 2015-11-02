require 'rails_helper'

RSpec.describe JobCategory, type: :model do

   
   describe 'Associations' do
    
     it { is_expected.to have_and_belong_to_many :skills }
     it { is_expected.to have_many :jobs }
     xit{ is_expected.to have_many_and_belong_to(:agency_people).join_table(:job_specialities)}
     
 
   
   end

   describe 'Database schema' do

    it { is_expected.to have_db_column :id }  
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description}
     
   end
   
   describe 'check model restrictions' do
    
     describe 'Name check' do
      subject {FactoryGirl.build(:job_category)}
       it { is_expected.to validate_presence_of :name }
     end

     describe 'Description check' do 
      subject {FactoryGirl.build(:job_category)}
       it { is_expected.to validate_presence_of :description }
     end

   end
  
end





  

