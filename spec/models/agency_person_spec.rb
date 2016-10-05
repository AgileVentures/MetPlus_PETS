require 'rails_helper'

RSpec.describe AgencyPerson, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency_person)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :agency }
    it { is_expected.to belong_to :branch }
    it { is_expected.to have_and_belong_to_many :agency_roles }
    it { is_expected.to have_and_belong_to_many(:job_categories).
            join_table('job_specialities')}
    it { is_expected.to have_many(:job_seekers).through(:agency_relations) }
    it { is_expected.to have_many(:status_changes) }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :agency_id }
    it { is_expected.to have_db_column :branch_id }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :agency_id }
    it 'invalidates removing admin role for sole agency admin' do
      person = FactoryGirl.create(:agency_person)
      role = AgencyRole.create(role: AgencyRole::ROLE[:AA])
      person.agency_roles << role
      expect(person).to be_valid
      person.agency_roles.delete(role)
      person.save
      expect(person).to_not be_valid
    end
    it 'invalidates assignment as job developer if does not have that role' do
      agency_person = FactoryGirl.build(:case_manager)
      agency_person.agency_relations << FactoryGirl.create(:agency_relation,
                            agency_person: agency_person,
                            job_seeker: FactoryGirl.create(:job_seeker),
                            agency_role: AgencyRole.create(role: AgencyRole::ROLE[:JD]))
      agency_person.valid?
      expect(agency_person.errors[:person]).
        to include('cannot be assigned as Job Developer unless person has that role.')
    end
    it 'invalidates assignment as case manager if does not have that role' do
      agency_person = FactoryGirl.build(:job_developer)
      agency_person.agency_relations << FactoryGirl.create(:agency_relation,
                            agency_person: agency_person,
                            job_seeker: FactoryGirl.create(:job_seeker),
                            agency_role: AgencyRole.create(role: AgencyRole::ROLE[:CM]))
      agency_person.valid?
      expect(agency_person.errors[:person]).
        to include('cannot be assigned as Case Manager unless person has that role.')
    end
    describe 'status' do
       it 'Status -1 should generate exception' do
         expect{subject.status = -1}.to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
       end
       it 'Status 0 should be invited' do
         subject.status = 0
         expect(subject.status).to eq 'invited'
       end
       it 'Status 1 should be active' do
         subject.status = 1
         expect(subject.status).to eq 'active'
       end
       it 'Status 2 should be inactive' do
         subject.status = 2
         expect(subject.status).to eq 'inactive'
       end
       it 'Status 3 should generate exception' do
         expect{subject.status = 3}.to raise_error(ArgumentError).with_message('\'3\' is not a valid status')
       end
    end
  end

  describe 'Agency Person' do
    it 'is valid with all required fields' do
      expect(AgencyPerson.new(agency_id: 1,
          email: 'agencyperson2@gmail.com', first_name: 'Agency',
          last_name: 'Person', password: 'qwerty123')).to be_valid
    end
    it 'is invalid without an agency association' do
      agency = AgencyPerson.new()
      agency.valid?
      expect(agency.errors[:agency_id]).to include("can't be blank")
    end
    context "#acting_as?" do
      it "returns true for supermodel class and name" do
        expect(AgencyPerson.acting_as? :user).to be true
        expect(AgencyPerson.acting_as? User).to  be true
      end
      it "returns false for anything other than supermodel" do
        expect(AgencyPerson.acting_as? :model).to be false
        expect(AgencyPerson.acting_as? String).to be false
      end
    end
  end

  describe 'Agency Admin checks' do
    let(:agency) { FactoryGirl.create(:agency) }
    let!(:aa_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role,
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let(:aa_person2)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role,
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let(:jd_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role,
                                      role: AgencyRole::ROLE[:JD])
      $person.save
      $person
    end

    it 'confirms sole agency admin' do
      expect(aa_person.sole_agency_admin?).to be true
    end
    it 'confirms not sole agency admin if not admin' do
      expect(jd_person.sole_agency_admin?).to be false
    end
    it 'confirms not sole agency admin if another admin' do
      expect(aa_person2.sole_agency_admin?).to be false
    end

  end
  describe 'Identity check with' do
    let(:agency) {FactoryGirl.create(:agency)}
    let(:agency1) {FactoryGirl.create(:agency)}
    describe '#is_job_developer?' do
      let(:person) {FactoryGirl.create(:job_developer, :agency => agency)}
      let(:person_other_agency) {FactoryGirl.create(:job_developer, :agency => agency1)}
      it 'correct' do
        expect(person.is_job_developer?(agency)).to be true
      end
      it 'incorrect' do
        expect(person_other_agency.is_job_developer?(agency)).to be false
      end
    end
    describe '#is_case_manager?' do
      let(:person) {FactoryGirl.create(:case_manager, :agency => agency)}
      let(:person_other_agency) {FactoryGirl.create(:case_manager, :agency => agency1)}
      it 'correct' do
        expect(person.is_case_manager?(agency)).to be true
      end
      it 'incorrect' do
        expect(person_other_agency.is_case_manager?(agency)).to be false
      end
    end
    describe '#is_agency_admin?' do
      let(:person) {FactoryGirl.create(:agency_admin, :agency => agency)}
      let(:person_other_agency) {FactoryGirl.create(:agency_admin, :agency => agency1)}
      it 'correct' do
        expect(person.is_agency_admin?(agency)).to be true
      end
      it 'incorrect' do
        expect(person_other_agency.is_agency_admin?(agency)).to be false
      end
    end
  end

  context 'job_seeker / agency_person relationships' do

    let(:agency)           { FactoryGirl.create(:agency) }
    let(:cm_person)        {FactoryGirl.create(:case_manager, agency: agency)}
    let(:jd_person)        {FactoryGirl.create(:job_developer, agency: agency)}
    let(:jd_and_cm_person) {FactoryGirl.create(:jd_cm, agency: agency)}

    10.times do |n|
      let("js#{n+1}".to_sym) {FactoryGirl.create(:job_seeker)}
    end

    before(:each) do

      # Assign first 3 job seekers to cm_person
      js1.assign_case_manager cm_person, agency
      js2.assign_case_manager cm_person, agency
      js3.assign_case_manager cm_person, agency
      #Assign next 3 to jd_person
      js4.assign_job_developer jd_person, agency
      js5.assign_job_developer jd_person, agency
      js6.assign_job_developer jd_person, agency
      #Assign next 2 to dual_role person as job developer
      js7.assign_job_developer jd_and_cm_person, agency
      js8.assign_job_developer jd_and_cm_person, agency
      #Assign next 2 to dual_role person as case manager
      js9.assign_case_manager jd_and_cm_person, agency
      js10.assign_case_manager jd_and_cm_person, agency
    end

    context '.job_seekers_as_job_developer' do

      it 'returns job seekers for job developer' do
        expect(jd_person.job_seekers_as_job_developer).to contain_exactly(js4, js5, js6)

      end
      it 'returns job seekers for dual-rol agency person' do
        expect(jd_and_cm_person.job_seekers_as_job_developer).to contain_exactly(js7, js8)

      end
      it 'returns no jobseekers for case manager' do
        expect(cm_person.job_seekers_as_job_developer.count).to be 0

      end

    end

    context 'job_seekers_as_case_manager' do

      it 'returns job seekers for case manager' do
        expect(cm_person.job_seekers_as_case_manager).to contain_exactly(js1, js2, js3)

      end
      it 'returns job seekers for dual-role agency person' do
        expect(jd_and_cm_person.job_seekers_as_case_manager).to contain_exactly(js9, js10)

      end

      it 'returns no job seekers for job developer' do
        expect(jd_person.job_seekers_as_case_manager.count).to be 0

       end

    end

  end
end
