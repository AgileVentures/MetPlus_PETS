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
   
   describe 'roles determination' do
     before :each do
       @job_seeker = FactoryGirl.create(:job_seeker)
       @jd_role = FactoryGirl.create(:agency_role, role: 'Job Developer')
       @am_role = FactoryGirl.create(:agency_role, role: 'Agency Manager')
       @cm_role = FactoryGirl.create(:agency_role, role: 'Case Manager')
       @aa_role = FactoryGirl.create(:agency_role, role: 'Agency Admin')
       
       @job_developer = FactoryGirl.build(:agency_person)
       @job_developer.agency_roles << @jd_role
       @job_developer.save
       
       @case_manager = FactoryGirl.create(:agency_person)
       @case_manager.agency_roles << @cm_role
       @case_manager.save

       @agency_admin = FactoryGirl.create(:agency_person)
       @agency_admin.agency_roles << @aa_role
       @agency_admin.save
                  
       @agency_manager = FactoryGirl.build(:agency_person)
       @agency_manager.agency_roles << [@am_role, @aa_role]       
       @agency_manager.save
     end
     it 'job seeker' do
       expect(User.is_job_seeker?(@job_seeker.user)).to be true
     end
     it 'job developer' do
       expect(User.is_job_developer?(@job_developer.user)).to be true
     end
     it 'case manager' do
       expect(User.is_case_manager?(@case_manager.user)).to be true
     end
     it 'agency admin' do
       expect(User.is_agency_admin?(@agency_admin.user)).to be true
     end
     it 'agency manager (also agency_admin role)' do
       expect(User.is_agency_manager?(@agency_manager.user)).to be true
       expect(User.is_agency_admin?(@agency_manager.user)).to be true
     end
   end
   
   describe 'company roles determination' do
     before :each do
      @ce_role = FactoryGirl.create(:company_role, role: 'Employee')
      @ca_role = FactoryGirl.create(:company_role, role: 'Company Admin')
              
      @employee = FactoryGirl.build(:company_person)
      @employee.company_roles << @ce_role
      @employee.save

      @company_admin = FactoryGirl.build(:company_person)
      @company_admin.company_roles << @ca_role
      @company_admin.save
                  
      end
      it 'company admin' do
       expect(User.is_company_admin?(@company_admin.user)).to be true
       end
      it ' employee' do
       expect(User.is_employee?(@employee.user)).to be true
       end
       
     end   



end



