require 'rails_helper'

RSpec.describe User, type: :model do
  
   
   
   describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :email}
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :actable_id }
    it { is_expected.to have_db_column :actable_type }
   end

   describe 'check model restrictions' do 

     describe 'Email check' do
       subject {FactoryGirl.build(:user)}
       it { should validate_uniqueness_of(:email)}
       it { should validate_presence_of(:email)}
       it { should_not allow_value('abc', 'abc@abc', 'abcdefghjjkll').for(:email)}
     end

     describe 'FirstName check' do
       subject {FactoryGirl.build(:user)}
       it { is_expected.to validate_presence_of :first_name }
       
     end

     describe 'LastName check' do
       subject {FactoryGirl.build(:user)}
       it { is_expected.to validate_presence_of :last_name }
       
     end

     describe 'Phone check' do
       subject {FactoryGirl.build(:user)}
       it { should_not allow_value('asd', '123456', '123 123 12345', '123 1231 1234', '1123 123 1234', ' 123 123 1234').for(:phone)}

       it { should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234', '1231231234', '+1 (123) 1231234').for(:phone)}

     end
       

       
     
   end

   
    
  
  

end



