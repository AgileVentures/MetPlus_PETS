require 'rails_helper'

RSpec.describe User, type: :model do
  
   
   
   describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :actable_id }
    it { is_expected.to have_db_column :actable_type }
   end

   describe 'check model restrictions' do 

     describe 'FirstName check' do
       subject {FactoryGirl.build(:user)}
       it { is_expected.to validate_presence_of :first_name }
       
     end

     describe 'LastName check' do
       subject {FactoryGirl.build(:user)}
       it { is_expected.to validate_presence_of :last_name }
       
     end

     describe 'Phone number format check' do
       subject {FactoryGirl.build(:user)}
       it { should_not allow_value('asd', '123456', '123 123 12345', '123 1231 1234', '1123 123 1234', ' 123 123 1234').for(:phone)}

       it { should allow_value('123 123 1234', '(123) 123 1234', '(123)-123 1234', '1231231234', '(123) 1231234').for(:phone)}

     end
       

       
     
   end

   
    
  
  

end



