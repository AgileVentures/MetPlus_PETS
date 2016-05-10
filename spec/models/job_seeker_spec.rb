require 'rails_helper'

describe JobSeeker, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:job_seeker)).to be_valid
    end
  end
  describe 'Database schema' do
    it {is_expected.to have_db_column :year_of_birth}
    it {is_expected.to have_db_column :job_seeker_status_id }
    it {is_expected.to have_db_column :resume }
    it {is_expected.to have_db_column :address_id }
  end
  describe 'check model restrictions' do
    it {is_expected.to validate_presence_of(:year_of_birth)}
    xit {is_expected.to validate_presence_of(:resume)}
    it {is_expected.to validate_presence_of(:job_seeker_status)}
    it {is_expected.to have_many(:agency_people).through(:agency_relations)}
    it {is_expected.to have_many(:job_applications)}
    it {is_expected.to have_many(:jobs).through(:job_applications)}
    it {is_expected.to belong_to(:address)}
    it {is_expected.to belong_to(:job_seeker_status)}

    it{should allow_value('1987', '1916', '2000', '2014').for(:year_of_birth)}
    it{should_not allow_value('1911', '899', '1890', 'salem').for(:year_of_birth)}

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

    before(:each) do
      adam.assign_case_manager(cm_person, agency)
      dave.assign_job_developer(jd_person, agency)
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
