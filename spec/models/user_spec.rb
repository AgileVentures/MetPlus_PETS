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
       @jd_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])
       @cm_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])
       @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
       
       @job_developer = FactoryGirl.build(:agency_person)
       @job_developer.agency_roles << @jd_role
       @job_developer.save
       
       @case_manager = FactoryGirl.create(:agency_person)
       @case_manager.agency_roles << @cm_role
       @case_manager.save

       @agency_admin = FactoryGirl.create(:agency_person)
       @agency_admin.agency_roles << @aa_role
       @agency_admin.save
       
       @cm_and_jd = FactoryGirl.create(:agency_person)
       @cm_and_jd.agency_roles << [@cm_role, @jd_role]
       @cm_and_jd.save
     end
     it 'job seeker' do
       expect(User.is_job_seeker?(@job_seeker.user)).to be true
       expect(User.is_job_seeker?(@job_developer.user)).not_to be true
       expect(User.is_job_seeker?(@case_manager.user)).not_to be true
       expect(User.is_job_seeker?(@agency_admin.user)).not_to be true
     end
     it 'job developer' do
       expect(User.is_job_developer?(@job_developer.user)).to be true
       expect(User.is_job_developer?(@job_seeker.user)).not_to be true
       expect(User.is_job_developer?(@case_manager.user)).not_to be true
       expect(User.is_job_developer?(@agency_admin.user)).not_to be true
     end
     it 'case manager' do
       expect(User.is_case_manager?(@case_manager.user)).to be true
       expect(User.is_case_manager?(@job_seeker.user)).not_to be true
       expect(User.is_case_manager?(@job_developer.user)).not_to be true
       expect(User.is_case_manager?(@agency_admin.user)).not_to be true
     end
     it 'agency admin' do
       expect(User.is_agency_admin?(@agency_admin.user)).to be true
       expect(User.is_agency_admin?(@case_manager.user)).not_to be true
       expect(User.is_agency_admin?(@job_developer.user)).not_to be true
       expect(User.is_agency_admin?(@job_seeker.user)).not_to be true
     end
     it 'case manager is also a job developer' do
       expect(User.is_case_manager?(@cm_and_jd.user)).to be true
       expect(User.is_job_developer?(@cm_and_jd.user)).to be true
     end
   end
   
   describe 'company roles determination' do
     before :each do
      @ec_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:EC])
      @ea_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:EA])
              
      @company_contact = FactoryGirl.build(:company_person)
      @company_contact.company_roles << @ec_role
      @company_contact.save

      @company_admin = FactoryGirl.build(:company_person)
      @company_admin.company_roles << @ea_role
      @company_admin.save       
    end
    it 'company admin' do
      expect(User.is_company_admin?(@company_admin.user)).to be true
      expect(User.is_company_admin?(@company_contact.user)).not_to be true
    end
    it 'company contact' do
      expect(User.is_company_contact?(@company_contact.user)).to be true
      expect(User.is_company_contact?(@company_admin.user)).not_to be true
    end
  end
end



