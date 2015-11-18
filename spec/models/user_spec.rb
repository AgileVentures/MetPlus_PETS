require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:user)).to be_valid
      end
  end
  
   describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :actable_id }
    it { is_expected.to have_db_column :actable_type }
    
    it { is_expected.to have_db_column :encrypted_password}
    it { is_expected.to have_db_column :reset_password_token}
    it { is_expected.to have_db_column :reset_password_sent_at}
    it { is_expected.to have_db_column :remember_created_at}
    it { is_expected.to have_db_column :sign_in_count}

    it { is_expected.to have_db_column :current_sign_in_at}
    it { is_expected.to have_db_column :last_sign_in_at}
    it { is_expected.to have_db_column :confirmation_token}
    it { is_expected.to have_db_column :current_sign_in_ip }
    it { is_expected.to have_db_column :last_sign_in_ip}
    it { is_expected.to have_db_column :confirmation_token}

    it { is_expected.to have_db_column :confirmed_at }
    it { is_expected.to have_db_column :confirmation_sent_at}
    it { is_expected.to have_db_column :unconfirmed_email}
   
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



