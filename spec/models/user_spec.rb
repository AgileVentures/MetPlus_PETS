require 'rails_helper'
include ServiceStubHelpers::EmailValidator

RSpec.describe User, type: :model do
  before :all do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
  after :all do
    WebMock.allow_net_connect!
  end

  before :each do
    stub_email_validate_valid
  end
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.create(:user)).to be_valid
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

    it { is_expected.to have_db_column :encrypted_password }
    it { is_expected.to have_db_column :reset_password_token }
    it { is_expected.to have_db_column :reset_password_sent_at }
    it { is_expected.to have_db_column :remember_created_at }
    it { is_expected.to have_db_column :sign_in_count }

    it { is_expected.to have_db_column :current_sign_in_at }
    it { is_expected.to have_db_column :last_sign_in_at }
    it { is_expected.to have_db_column :confirmation_token }
    it { is_expected.to have_db_column :current_sign_in_ip }
    it { is_expected.to have_db_column :last_sign_in_ip }
    it { is_expected.to have_db_column :confirmation_token }

    it { is_expected.to have_db_column :confirmed_at }
    it { is_expected.to have_db_column :confirmation_sent_at }
    it { is_expected.to have_db_column :unconfirmed_email }
  end

  describe 'check model restrictions' do
    describe 'FirstName check' do
      subject { FactoryBot.build(:user) }
      it { is_expected.to validate_presence_of :first_name }
    end

    describe 'LastName check' do
      subject { FactoryBot.build(:user) }
      it { is_expected.to validate_presence_of :last_name }
    end

    describe 'Phone number format check' do
      subject { FactoryBot.build(:user) }
      it {
        should_not allow_value('asd', '123456', '123 1231  1234', '1    123 123 1234',
                               ' 123 123 1234', '(234 1234 1234',
                               '786) 1243 3578').for(:phone)
      }
      it {
        should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
                           '1 231 231 2345', '12312312345', '1231231234',
                           '1-910-123-9158 x2851', '1-872-928-5886',
                           '833-638-6551 x16825').for(:phone)
      }
    end

    describe 'Email validation' do
      let(:user) { FactoryBot.create(:user) }

      it 'valid email address' do
        user.email = 'thisone@yahoo.com'
        expect(user).to be_valid
      end

      it 'missing email' do
        user.email = ''
        expect(user).not_to be_valid
      end

      it 'validate service not available' do
        stub_email_validate_error

        user.email = 'emailaddress@gmal.com'
        expect(user).to be_valid
      end

      it 'adds an error to object when validation fails' do
        stub_email_validate_invalid
        # Turn on mailgun validation so the stub is effective
        ENV['MAILGUN_EMAIL_VALIDATION'] = 'yes'

        user = FactoryBot.build(:user, email: 'emailaddress@gmal.com')
        user.valid?
        expect(user.errors[:email])
          .to include('is not valid (did you mean ... myaddress@gmail.com?)')

        ENV['MAILGUN_EMAIL_VALIDATION'] = nil
      end
    end
  end

  describe 'roles determination' do
    before :each do
      @job_seeker = FactoryBot.create(:job_seeker)
      @jd_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:AA])

      @job_developer = FactoryBot.build(:agency_person)
      @job_developer.agency_roles << @jd_role
      @job_developer.save

      @case_manager = FactoryBot.create(:agency_person)
      @case_manager.agency_roles << @cm_role
      @case_manager.save

      @agency_admin = FactoryBot.create(:agency_person)
      @agency_admin.agency_roles << @aa_role
      @agency_admin.save

      @cm_and_jd = FactoryBot.create(:agency_person)
      @cm_and_jd.agency_roles << [@cm_role, @jd_role]
      @cm_and_jd.save
    end
    it 'job seeker' do
      expect(User.job_seeker?(@job_seeker.user)).to be true
      expect(User.job_seeker?(@job_developer.user)).not_to be true
      expect(User.job_seeker?(@case_manager.user)).not_to be true
      expect(User.job_seeker?(@agency_admin.user)).not_to be true
    end
    it 'job developer' do
      expect(User.job_developer?(@job_developer.user)).to be true
      expect(User.job_developer?(@job_seeker.user)).not_to be true
      expect(User.job_developer?(@case_manager.user)).not_to be true
      expect(User.job_developer?(@agency_admin.user)).not_to be true
    end
    it 'case manager' do
      expect(User.case_manager?(@case_manager.user)).to be true
      expect(User.case_manager?(@job_seeker.user)).not_to be true
      expect(User.case_manager?(@job_developer.user)).not_to be true
      expect(User.case_manager?(@agency_admin.user)).not_to be true
    end
    it 'agency admin' do
      expect(User.agency_admin?(@agency_admin.user)).to be true
      expect(User.agency_admin?(@case_manager.user)).not_to be true
      expect(User.agency_admin?(@job_developer.user)).not_to be true
      expect(User.agency_admin?(@job_seeker.user)).not_to be true
    end
    it 'case manager is also a job developer' do
      expect(User.case_manager?(@cm_and_jd.user)).to be true
      expect(User.job_developer?(@cm_and_jd.user)).to be true
    end
  end

  describe 'company roles determination' do
    before :each do
      @ec_role = FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ea_role = FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company_contact = FactoryBot.build(:company_person)
      @company_contact.company_roles << @ec_role
      @company_contact.save

      @company_admin = FactoryBot.build(:company_person)
      @company_admin.company_roles << @ea_role
      @company_admin.save
    end
    it 'company admin' do
      expect(User.company_admin?(@company_admin.user)).to be true
      expect(User.company_admin?(@company_contact.user)).not_to be true
    end
    it 'company contact' do
      expect(User.company_contact?(@company_contact.user)).to be true
      expect(User.company_contact?(@company_admin.user)).not_to be true
    end

    context 'when user is nil' do
      it 'company admin' do
        expect(User.company_admin?(nil)).not_to be true
      end
      it 'company contact' do
        expect(User.company_contact?(nil)).not_to be true
      end
    end
  end
  describe '#full_name' do
    it 'returns full name of user' do
      agency_person = FactoryBot.build(:agency_person)
      expect(agency_person.full_name)
        .to eq "#{agency_person.last_name}, #{agency_person.first_name}"
      expect(agency_person.full_name(last_name_first: false))
        .to eq "#{agency_person.first_name} #{agency_person.last_name}"
    end
  end
  describe '#pets_user' do
    it 'job seeker' do
      job_seeker = FactoryBot.create(:job_seeker)
      user = User.find_by_id job_seeker.user.id
      expect(user).to be_a User
      expect(user).not_to be_a JobSeeker
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a JobSeeker
    end
    it 'job developer' do
      job_developer = FactoryBot.create(:job_developer)
      user = User.find_by_id job_developer.user.id
      expect(user).to be_a User
      expect(user).not_to be_a AgencyPerson
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a AgencyPerson
    end
    it 'case manager' do
      case_manager = FactoryBot.create(:case_manager)
      user = User.find_by_id case_manager.user.id
      expect(user).to be_a User
      expect(user).not_to be_a AgencyPerson
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a AgencyPerson
    end
    it 'agency admin' do
      agency_admin = FactoryBot.create(:agency_admin)
      user = User.find_by_id agency_admin.user.id
      expect(user).to be_a User
      expect(user).not_to be_a AgencyPerson
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a AgencyPerson
    end
    it 'company admin' do
      company_admin = FactoryBot.create(:company_admin)
      user = User.find_by_id company_admin.user.id
      expect(user).to be_a User
      expect(user).not_to be_a CompanyPerson
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a CompanyPerson
    end
    it 'company contact' do
      company_contact = FactoryBot.create(:company_contact)
      user = User.find_by_id company_contact.user.id
      expect(user).to be_a User
      expect(user).not_to be_a CompanyPerson
      expect(user.pets_user).not_to be_a User
      expect(user.pets_user).to be_a CompanyPerson
    end
  end
  describe '#job_developer?' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:person) { FactoryBot.create(:job_developer, agency: agency) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.job_developer?(agency)).to be false
    end
  end
  describe '#case_manager?' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:person) { FactoryBot.create(:case_manager, agency: agency) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.case_manager?(agency)).to be false
    end
  end
  describe '#agency_admin?' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:person) { FactoryBot.create(:agency_admin, agency: agency) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.agency_admin?(agency)).to be false
    end
  end
  describe '#job_seeker?' do
    let(:agency) { FactoryBot.create(:agency) }
    let(:person) { FactoryBot.create(:job_seeker) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.job_seeker?).to be false
    end
  end
  describe '#company_contact?' do
    let(:company) { FactoryBot.create(:company) }
    let(:person) { FactoryBot.create(:company_contact, company: company) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.company_contact?(company)).to be false
    end
  end
  describe '#company_admin?' do
    let(:company) { FactoryBot.create(:company) }
    let(:person) { FactoryBot.create(:company_admin, company: company) }
    let(:user) { User.find_by_id person.user.id }
    it 'false' do
      expect(user.company_admin?(company)).to be false
    end
  end
  describe '#inactive_message' do
    context 'as a inactive job seeker' do
      let(:agency) { FactoryBot.create(:agency) }
      let(:person) { FactoryBot.create(:job_seeker) }

      it 'returns inactive' do
        expect(person.inactive_message).to be :inactive
      end
    end
    context 'as a inactive case manager' do
      let(:agency) { FactoryBot.create(:agency) }
      let(:person) { FactoryBot.create(:case_manager, agency: agency) }

      it 'returns inactive' do
        expect(person.inactive_message).to be :inactive
      end
    end
    context 'as a inactive job developer' do
      let(:agency) { FactoryBot.create(:agency) }
      let(:person) { FactoryBot.create(:job_developer, agency: agency) }

      it 'returns inactive' do
        expect(person.inactive_message).to be :inactive
      end
    end
    context 'as a company person' do
      context 'from an inactive company' do
        let(:company) { FactoryBot.create(:inactive_company) }
        let(:person) { FactoryBot.create(:pending_first_company_admin, company: company) }
        it 'returns signed_up_but_not_approved' do
          expect(person.inactive_message).to be :signed_up_but_not_approved
        end
      end
      context 'from a company that was denied access to PETS' do
        let(:company) { FactoryBot.create(:company) }
        let(:person) do
          FactoryBot.create(:pending_first_company_admin,
                            company: company, status: 'company_denied')
        end
        it 'returns not_approved' do
          expect(person.inactive_message).to be :not_approved
        end
      end
      context 'from a company that is no longer active' do
        let(:company) { FactoryBot.create(:inactive_company) }
        let(:person) { FactoryBot.create(:company_contact, company: company) }
        it 'returns company_no_longer_active' do
          expect(person.inactive_message).to be :company_no_longer_active
        end
      end
    end
  end
end
