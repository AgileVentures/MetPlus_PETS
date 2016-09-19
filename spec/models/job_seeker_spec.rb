require 'rails_helper'

include ServiceStubHelpers::Cruncher

describe JobSeeker, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:job_seeker)).to be_valid
    end
  end
  describe 'Database schema' do
    it {is_expected.to have_db_column :year_of_birth}
    it {is_expected.to have_db_column :job_seeker_status_id }
    it {is_expected.to have_db_column :address_id }
  end
  describe 'check model restrictions' do
    it {is_expected.to validate_presence_of(:year_of_birth)}
    it {is_expected.to validate_presence_of(:job_seeker_status)}
    it {is_expected.to have_many(:agency_people).through(:agency_relations)}
    it {is_expected.to have_many(:job_applications)}
    it {is_expected.to have_many(:jobs).through(:job_applications)}
    it {is_expected.to belong_to(:address)}
    it {is_expected.to belong_to(:job_seeker_status)}

    it{should allow_value('1987', '1916', '2000', '2014').for(:year_of_birth)}
    it{should_not allow_value('1911', '899', '1890', 'salem').for(:year_of_birth)}

  end

  describe "#latest_application" do
    let!(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let!(:resume)     { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let(:job1)        { FactoryGirl.create(:job) }
    let(:job2)        { FactoryGirl.create(:job) }
    let(:test_file)   { '../fixtures/files/Admin-Assistant-Resume.pdf' }

    it 'returns last application for job seeker' do

      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download test_file

      job1.apply job_seeker
      expect(job_seeker.latest_application).to eq job1.job_applications[0]
      job2.apply job_seeker
      expect(job_seeker.latest_application).to eq job2.job_applications[0]
    end
  end

  describe "#with_ap_in_role" do
    let!(:jd_role) { FactoryGirl.create(:agency_role,
                                       role: AgencyRole::ROLE[:JD])}
    let!(:cm_role) { FactoryGirl.create(:agency_role,
                                       role: AgencyRole::ROLE[:CM])}

    let(:job_seeker1) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker3) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker4) { FactoryGirl.create(:job_seeker) }

    let(:job_developer) { FactoryGirl.create(:job_developer) }
    let(:case_manager)  { FactoryGirl.create(:case_manager) }

    before(:each) do
      FactoryGirl.create(:agency_relation, job_seeker: job_seeker1,
                          agency_person: job_developer, agency_role: jd_role)
      FactoryGirl.create(:agency_relation, job_seeker: job_seeker2,
                          agency_person: job_developer, agency_role: jd_role)

      FactoryGirl.create(:agency_relation, job_seeker: job_seeker3,
                          agency_person: case_manager, agency_role: cm_role)
      FactoryGirl.create(:agency_relation, job_seeker: job_seeker4,
                          agency_person: case_manager, agency_role: cm_role)
    end

    it 'returns IDs of job seekers assigned to this job developer' do
      expect(JobSeeker.with_ap_in_role(:JD, job_developer)).
            to contain_exactly(job_seeker1.id, job_seeker2.id)
    end
    it 'returns IDs of job seekers assigned to this case manager' do
      expect(JobSeeker.with_ap_in_role(:CM, case_manager)).
            to contain_exactly(job_seeker3.id, job_seeker4.id)
    end
end


  context "#acting_as?" do
    it "returns true for supermodel class and name" do
      expect(JobSeeker.acting_as? :user).to be true
      expect(JobSeeker.acting_as? User).to  be true
    end

    it "returns false for anything other than supermodel" do
      expect(JobSeeker.acting_as? :model).to be false
      expect(JobSeeker.acting_as? String).to be false
    end
  end
  describe '#is_job_seeker?' do
    let(:person) {FactoryGirl.create(:job_seeker)}
    it 'true' do
      expect(person.is_job_seeker?).to be true
    end
  end

  context 'job_seeker / agency_person relationships' do
    let(:agency) { FactoryGirl.create(:agency) }

    let!(:cm_person) {FactoryGirl.create(:case_manager, first_name: 'John', last_name: 'Manager', agency: agency)}
    let!(:cm_person2) {FactoryGirl.create(:case_manager, first_name: 'Jane', last_name: 'Manager2', agency: agency)}
    let!(:jd_person) {FactoryGirl.create(:job_developer, first_name: 'John', last_name: 'Developer', agency: agency)}
    let!(:aa_person) {FactoryGirl.create(:agency_admin, first_name: 'John', last_name: 'Admin', agency: agency)}

    let!(:adam)    { FactoryGirl.create(:job_seeker, first_name: 'Adam', last_name: 'Smith') }
    let!(:bob)     { FactoryGirl.create(:job_seeker, first_name: 'Bob', last_name: 'Smith') }
    let!(:charles) { FactoryGirl.create(:job_seeker, first_name: 'Charles', last_name: 'Smith') }
    let!(:dave)    { FactoryGirl.create(:job_seeker, first_name: 'Dave', last_name: 'Smith') }

    FactoryGirl.create(:agency_role)
    FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])

    before(:each) do
      adam.assign_case_manager(cm_person, agency)
      dave.assign_job_developer(jd_person, agency)
    end

    describe 'class methods for job seekers agency relations' do
      it '.job_seekers_without_job_developer returns job seekers with no job developer' do
        expect(JobSeeker.job_seekers_without_job_developer).to match([adam, bob, charles])
      end
      it '.job_seekers_without_case_manager returns job seekers with no case manager' do
        expect(JobSeeker.job_seekers_without_case_manager).to match([bob, charles, dave])
        
      end
    end

    describe '#assign_case_manager' do
      it 'success' do
        bob.assign_case_manager(cm_person, agency)
        expect(bob.case_manager).to eq(cm_person)
      end
      it 'not a case manager' do
        expect{bob.assign_case_manager jd_person, agency}.to raise_error("User Developer, John is not a Case Manager")
      end
    end
    describe '#assign_job_developer' do
      it 'success' do
        bob.assign_job_developer(jd_person, agency)
        expect(bob.job_developer).to eq(jd_person)
      end
      it 'not a job developer' do
        expect{bob.assign_job_developer cm_person, agency}.to raise_error("User Manager, John is not a Job Developer")
      end
    end
    describe '#case_manager' do
      it 'success' do
        expect(adam.case_manager).to eq(cm_person)
      end
      it 'no case manager' do
        expect(dave.case_manager).to eq(nil)
      end
    end
    describe '#job_developer' do
      it 'success' do
        expect(dave.job_developer).to eq(jd_person)
      end
      it 'no job developer' do
        expect(adam.job_developer).to eq(nil)
      end
    end
    describe '#reassign agency person' do
      it 'replaces current case manager' do
        adam.assign_case_manager(cm_person2, agency)
        expect(adam.case_manager).to eq(cm_person2)
      end
      it 'replaces current job developer' do
        dave.assign_case_manager(cm_person2, agency)
        expect(dave.case_manager).to eq(cm_person2)
      end
    end
  end
end
