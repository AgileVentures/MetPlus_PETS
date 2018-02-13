require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Company, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:company)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:company_people).dependent(:destroy) }
    it { is_expected.to have_many(:addresses).dependent(:destroy) }
    it { is_expected.to have_many :jobs }
    it { is_expected.to have_and_belong_to_many :agencies }
    it do
      is_expected.to accept_nested_attributes_for(:addresses).allow_destroy(true)
    end
    it { is_expected.to have_many(:status_changes).dependent(:destroy) }
    it { is_expected.to have_many :skills }
    describe 'dependent: :destroy' do
      let(:company) { FactoryBot.create(:company, status: :pending_registration) }
      let(:address) { FactoryBot.create(:address) }
      let(:company_person) { FactoryBot.create(:company_admin, company: company) }
      it 'destroys company_people with association when company is destroyed' do
        company_person
        expect { company.destroy }.to \
          change { company.company_people.count }.from(1).to(0).and \
            change { CompanyPerson.count }.by(-1)
      end
      it 'destroys addresses with association when company is destroyed' do
        company.addresses << address
        expect { company.destroy }.to \
          change { company.addresses.count }.from(1).to(0).and \
            change { Address.count }.by(-1)
      end
      it 'destroys status_changes with association when company is destroyed' do
        company.active
        statuses = company.status_changes
        expect { company.destroy }.to \
          change { statuses.count }.from(1).to(0).and \
            change { StatusChange.count }.by(-1)
      end
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :ein }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :fax }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :website }
    it { is_expected.to have_db_column :job_email }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validation' do
    describe 'EIN' do
      subject { FactoryBot.build(:company) }
      it do
        should_not allow_value('asd', '123456', '123-456789',
                               '12-34567891', '00-0000000',
                               '000000000').for(:ein)
      end

      it { should allow_value('12-3456789', '123456789').for(:ein) }
      it do
        is_expected.to validate_presence_of(:ein).with_message('is missing')
      end
      it do
        is_expected.to validate_uniqueness_of(:ein)
          .case_insensitive
          .with_message('has already been registered')
      end
    end

    describe 'phone' do
      subject { FactoryBot.build(:company) }
      it do
        should_not allow_value('asd', '123456', '123 1231  1234',
                               '1    123 123 1234', ' 123 123 1234',
                               '(234 1234 1234', '786) 1243 3578').for(:phone)
      end
      it do
        should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
                           '1 231 231 2345', '12312312345', '1231231234',
                           '1-910-123-9158 x2851', '1-872-928-5886',
                           '833-638-6551 x16825').for(:phone)
      end
    end

    describe 'fax' do
      subject { FactoryBot.build(:company) }
      it do
        should_not allow_value('asd', '123456', '123 1231  1234',
                               '1    123 123 1234', ' 123 123 1234',
                               '(234 1234 1234', '786) 1243 3578').for(:fax)
      end
      it do
        should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
                           '1 231 231 2345', '12312312345', '1231231234',
                           '1-910-123-9158 x2851', '1-872-928-5886',
                           '833-638-6551 x16825').for(:fax)
      end
    end

    describe 'Email' do
      let!(:company) { FactoryBot.build(:company) }
      it do
        stub_email_validate_error
        company.email = 'asd'
        expect(company).not_to be_valid
        company.email = 'john@company'
        expect(company).not_to be_valid
      end
      it { should allow_value('johndoe@company.com').for(:email) }
    end

    describe 'Website' do
      subject { FactoryBot.build(:company) }
      it do
        should_not allow_value('asd', 'ftp://company.com', 'http:',
                               'http://', 'https', 'https:', 'https://',
                               'http://place.com###Bammm').for(:website)
      end

      it do
        should allow_value('http://company.com',
                           'https://company.com',
                           'http://w.company.com/info',
                           'https://comp.com:10/test/1/wasd',
                           'http://company.com/').for(:website)
      end
    end

    describe 'Name check' do
      subject { FactoryBot.build(:company) }
      it { is_expected.to validate_presence_of :name }
    end

    describe 'Job Email' do
      it { should validate_presence_of(:job_email) }
      it do
        stub_email_validate_error
        should_not allow_value('asd', 'john@company').for(:job_email)
      end
      it { should allow_value('johndoe@company.com').for(:job_email) }
    end

    describe 'status' do
      it 'Status -1 should generate exception' do
        expect { subject.status = -1 }.to raise_error(ArgumentError)
          .with_message('\'-1\' is not a valid status')
      end
      it 'Status 0 should be pending_registration' do
        subject.status = 0
        expect(subject.status).to eq 'pending_registration'
      end
      it 'Status 1 should be active' do
        subject.status = 1
        expect(subject.status).to eq 'active'
      end
      it 'Status 2 should be inactive' do
        subject.status = 2
        expect(subject.status).to eq 'inactive'
      end
      it 'Status 3 should be registration_denied' do
        subject.status = 3
        expect(subject.status).to eq 'registration_denied'
      end
      it 'Status 4 should generate error' do
        expect { subject.status = 4 }.to raise_error(ArgumentError)
          .with_message('\'4\' is not a valid status')
      end
    end
  end

  describe 'Class and Instance methods' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
    end

    let(:company1) { FactoryBot.create(:company) }
    let(:company2) { FactoryBot.create(:company, name: 'Gadgets, Inc.') }
    let!(:company3) { FactoryBot.create(:company, name: 'Things, Inc.') }
    let!(:company4) { FactoryBot.create(:company, name: 'Widgets, Inc.') }
    let!(:company5) { FactoryBot.create(:company, name: 'Acme, Inc.') }
    let!(:company6) do
      FactoryBot.create(:company, name: 'InActive, Inc.',
                                  status: 'inactive')
    end

    let(:cmpy1_person) { FactoryBot.create(:company_contact, company: company1) }
    let(:cmpy2_person) { FactoryBot.create(:company_contact, company: company2) }
    let(:cmpy4_person) { FactoryBot.create(:company_contact, company: company4) }
    let(:cmpy5_person) { FactoryBot.create(:company_contact, company: company5) }
    let(:cmpy6_person) { FactoryBot.create(:company_contact, company: company6) }

    let!(:job1) do
      FactoryBot.create(:job, company: company1,
                              company_person: cmpy1_person)
    end
    let!(:job2) do
      FactoryBot.create(:job, company: company1,
                              company_person: cmpy1_person)
    end
    let!(:job3) do
      FactoryBot.create(:job, company: company2,
                              company_person: cmpy2_person)
    end
    let!(:job4) do
      FactoryBot.create(:job, company: company2,
                              company_person: cmpy2_person)
    end
    let!(:job5) do
      FactoryBot.create(:job, company: company4,
                              company_person: cmpy4_person,
                              status: :filled)
    end
    let!(:job6) do
      FactoryBot.create(:job, company: company5,
                              company_person: cmpy5_person,
                              status: :revoked)
    end
    let!(:job7) do
      FactoryBot.create(:job, company: company6,
                              company_person: cmpy6_person)
    end

    let!(:cmpy1_admin1) { FactoryBot.create(:company_admin, company: company1) }
    let!(:cmpy1_admin2) { FactoryBot.create(:company_admin, company: company1) }
    let!(:cmpy2_admin1) { FactoryBot.create(:company_admin, company: company2) }
    let!(:cmpy2_admin2) { FactoryBot.create(:company_admin, company: company2) }
    let!(:cmpy3_admin)  { FactoryBot.create(:company_admin, company: company3) }

    describe '.all_active_with_jobs' do
      it 'returns all active companies with job(s)' do
        expect(Company.all_active_with_jobs).to match_array [company1, company2,
                                                             company4, company5]
      end
    end
    describe '.company_admins' do
      it 'returns all admins for a company' do
        expect(Company.company_admins(company1))
          .to include(cmpy1_admin1, cmpy1_admin2)
        expect(Company.company_admins(company1))
          .to_not include(cmpy2_admin1, cmpy2_admin2)
        expect(Company.company_admins(company2))
          .to include(cmpy2_admin1, cmpy2_admin2)
        expect(Company.company_admins(company2))
          .to_not include(cmpy1_admin1, cmpy1_admin2)
      end
    end
    describe '.everyone' do
      it 'returns all company people for a company' do
        expect(Company.everyone(company1))
          .to include(cmpy1_person, cmpy1_admin1, cmpy1_admin2)
        expect(Company.everyone(company1))
          .to_not include(cmpy2_person, cmpy2_admin1, cmpy2_admin2)
        expect(Company.everyone(company2))
          .to include(cmpy2_person, cmpy2_admin1, cmpy2_admin2)
        expect(Company.everyone(company2))
          .to_not include(cmpy1_person, cmpy1_admin1, cmpy1_admin2)
      end
    end
    describe '#people_on_role' do
      it 'returns company people who have specified role' do
        expect(company3.people_on_role(CompanyRole::ROLE[:CA]))
          .to match_array [cmpy3_admin]
        expect(company3.people_on_role(CompanyRole::ROLE[:CC]))
          .to be_empty
        expect(company1.people_on_role(CompanyRole::ROLE[:CA]))
          .to match_array [cmpy1_admin1, cmpy1_admin2]
        expect(company1.people_on_role(CompanyRole::ROLE[:CC]))
          .to match_array [cmpy1_person]
        expect(company2.people_on_role(CompanyRole::ROLE[:CA]))
          .to match_array [cmpy2_admin1, cmpy2_admin2]
        expect(company2.people_on_role(CompanyRole::ROLE[:CC]))
          .to match_array [cmpy2_person]
      end
    end
  end
end
