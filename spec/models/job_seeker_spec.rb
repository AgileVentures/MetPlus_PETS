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
  end
  describe 'check model restrictions' do
  	it {is_expected.to validate_presence_of(:year_of_birth)}
  	xit {is_expected.to validate_presence_of(:resume)}
    it {is_expected.to validate_presence_of(:job_seeker_status_id)}
  	it {is_expected.to have_many(:agency_people).through(:agency_relations)}

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

    let!(:aa_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA]) }
    let!(:jd_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD]) }
    let!(:cm_role) { FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM]) }

    let!(:aa_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << aa_role
      $person.save
      $person
    end
    let!(:cm_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << cm_role
      $person.save
      $person
    end
    let!(:jd_person)   do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << jd_role
      $person.save
      $person
    end
    let!(:adam)    { FactoryGirl.create(:job_seeker, first_name: 'Adam', last_name: 'Smith') }
    let!(:bob)     { FactoryGirl.create(:job_seeker, first_name: 'Bob', last_name: 'Smith') }
    let!(:charles) { FactoryGirl.create(:job_seeker, first_name: 'Charles', last_name: 'Smith') }
    let!(:dave)    { FactoryGirl.create(:job_seeker, first_name: 'Dave', last_name: 'Smith') }

    before(:each) do
      cm_person.agency_relations << AgencyRelation.new(agency_role: cm_role,
                                          job_seeker: adam)
      cm_person.save!
      jd_person.agency_relations << AgencyRelation.new(agency_role: jd_role,
                                          job_seeker: dave)
      jd_person.save!
    end

    it 'returns a case manager for a given job seeker' do
      expect(adam.case_manager).to eq(cm_person)
    end
    it 'returns a job developer for a given job seeker' do
      expect(dave.job_developer).to eq(jd_person)
    end

    it 'assigns an agency person to a job seeker in a given role' do
      bob.assign_agency_person(jd_person, :JD)
      expect(bob.job_developer).to eq(jd_person)
    end

    it 'finds the agency relation for a job seeker in a given role' do
      expect(dave.find_agency_person(:JD)).to eq(jd_person)
    end

  end

end
