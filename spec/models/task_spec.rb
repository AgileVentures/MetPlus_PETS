require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:task)).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }

    it { is_expected.to have_db_column :target_user_id }

    it { is_expected.to have_db_column :target_agency_id }
    it { is_expected.to have_db_column :target_agency_role }

    it { is_expected.to have_db_column :target_company_id }
    it { is_expected.to have_db_column :target_company_role }

    it { is_expected.to have_db_column :deferred_date}
    it { is_expected.to have_db_column :user_id}
    it { is_expected.to have_db_column :job_id}
    it { is_expected.to have_db_column :company_id}
  end
  describe 'Setting owner of the task' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @jd_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @job_developer = FactoryGirl.build(:agency_person)
      @job_developer.agency_roles << @jd_role
      @job_developer.save
      @job_developer1 = FactoryGirl.build(:agency_person)
      @job_developer1.agency_roles << @jd_role
      @job_developer1.save
      @job_developer2 = FactoryGirl.build(:agency_person)
      @job_developer2.agency_roles << @jd_role
      @job_developer2.save
      @agency.agency_people << @job_developer1
      @agency.agency_people << @job_developer2

      @case_manager = FactoryGirl.create(:agency_person)
      @case_manager.agency_roles << @cm_role
      @case_manager.save
      @case_manager1 = FactoryGirl.create(:agency_person)
      @case_manager1.agency_roles << @cm_role
      @case_manager1.save
      @case_manager2 = FactoryGirl.create(:agency_person)
      @case_manager2.agency_roles << @cm_role
      @case_manager2.save
      @agency.agency_people << @case_manager1
      @agency.agency_people << @case_manager2

      @agency_admin = FactoryGirl.create(:agency_person)
      @agency_admin.agency_roles << @aa_role
      @agency_admin.save
      @agency_admin1 = FactoryGirl.create(:agency_person)
      @agency_admin1.agency_roles << @aa_role
      @agency_admin1.save
      @agency.agency_people << @agency_admin1

      @cm_and_jd = FactoryGirl.create(:agency_person)
      @cm_and_jd.agency_roles << [@cm_role, @jd_role]
      @cm_and_jd.save
      @task = FactoryGirl.create(:task)
      @agency.agency_people << @cm_and_jd
    end
    it 'job seeker user' do
      @task.task_owner = {:user => @job_seeker}
      expect(@task.task_owner).to be @job_seeker
    end
    it 'job developer user' do
      @task.task_owner = {:user => @job_developer}
      expect(@task.task_owner).to be @job_developer
    end
    it 'case manager user' do
      @task.task_owner = {:user => @case_manager}
      expect(@task.task_owner).to be @case_manager
    end
    it 'agency admin user' do
      @task.task_owner = {:user => @agency_admin}
      expect(@task.task_owner).to be @agency_admin
    end
    it 'job developer role' do
      @task.task_owner = {:agency => {agency: @agency, role: :JD}}
      expect(@task.task_owner).to eq [@job_developer1, @job_developer2, @cm_and_jd]
    end
    it 'case manager role' do
      @task.task_owner = {:agency => {agency: @agency, role: :CM}}
      expect(@task.task_owner).to eq [@case_manager1, @case_manager2, @cm_and_jd]
    end
    it 'agency admin role' do
      @task.task_owner = {:agency => {agency: @agency, role: :AA}}
      expect(@task.task_owner).to eq [@agency_admin1]
    end
  end
end
