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

      @job_developer = FactoryGirl.create(:agency_person, :agency_roles => [@jd_role])
      @job_developer1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@jd_role])
      @job_developer2 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@jd_role])

      @case_manager = FactoryGirl.create(:agency_person, :agency_roles => [@cm_role])
      @case_manager1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role])
      @case_manager2 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role])

      @agency_admin = FactoryGirl.create(:agency_person, :agency_roles => [@aa_role])
      @agency_admin1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])

      @cm_and_jd = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role, @jd_role])


      @cc_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ca_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company = FactoryGirl.create(:company)
      @company1 = FactoryGirl.create(:company)
      @company_contact = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@cc_role])
      @company_contact1 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@cc_role])
      @company_contact2 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@cc_role])


      @company_admin = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@ca_role])
      @company_admin1 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@ca_role])


      @task = FactoryGirl.create(:task)
    end
    it 'job seeker user' do
      @task.task_owner = {:user => @job_seeker}
      expect(@task.task_owner).to eq @job_seeker
    end
    it 'job developer user' do
      @task.task_owner = {:user => @job_developer}
      expect(@task.task_owner).to eq @job_developer
    end
    it 'case manager user' do
      @task.task_owner = {:user => @case_manager}
      expect(@task.task_owner).to eq @case_manager
    end
    it 'agency admin user' do
      @task.task_owner = {:user => @agency_admin}
      expect(@task.task_owner).to eq @agency_admin
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
    it 'company admin role' do
      @task.task_owner = {:company => {company: @company, role: :CA}}
      expect(@task.task_owner).to eq [@company_admin1]
    end
    it 'company contact role' do
      @task.task_owner = {:company => {company: @company, role: :CC}}
      expect(@task.task_owner).to eq [@company_contact1, @company_contact2]
    end
  end
  describe 'Find all tasks for a owner' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @jd_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @job_developer = FactoryGirl.create(:agency_person, :agency_roles => [@jd_role])
      @job_developer1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@jd_role])
      @job_developer2 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@jd_role])

      @case_manager = FactoryGirl.create(:agency_person, :agency_roles => [@cm_role])
      @case_manager1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role])
      @case_manager2 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role])

      @agency_admin = FactoryGirl.create(:agency_person, :agency_roles => [@aa_role])
      @agency_admin1 = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])

      @cm_and_jd = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role, @jd_role])


      @cc_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ca_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company = FactoryGirl.create(:company)
      @company1 = FactoryGirl.create(:company)
      @company_contact = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@cc_role])
      @company_contact1 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@cc_role])
      @company_contact2 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@cc_role])


      @company_admin = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@ca_role])
      @company_admin1 = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@ca_role])


      @task_js = FactoryGirl.create(:task)
      @task_js.task_owner = {:user => @job_seeker}
      @task_js.save

      @task_jd = FactoryGirl.create(:task)
      @task_jd.task_owner = {:user => @job_developer1}
      @task_jd.save
      @task_all_jd = FactoryGirl.create(:task)
      @task_all_jd.task_owner = {:agency => {agency: @agency, role: :JD}}
      @task_all_jd.save

      @task_cm = FactoryGirl.create(:task)
      @task_cm.task_owner = {:user => @case_manager1}
      @task_cm.save
      @task_all_cm = FactoryGirl.create(:task)
      @task_all_cm.task_owner = {:agency => {agency: @agency, role: :CM}}
      @task_all_cm.save

      @task_aa = FactoryGirl.create(:task)
      @task_aa.task_owner = {:user => @agency_admin1}
      @task_aa.save
      @task_all_aa = FactoryGirl.create(:task)
      @task_all_aa.task_owner = {:agency => {agency: @agency, role: :AA}}
      @task_all_aa.save

      @task_ca = FactoryGirl.create(:task)
      @task_ca.task_owner = {:user => @company_admin1}
      @task_ca.save
      @task_all_ca = FactoryGirl.create(:task)
      @task_all_ca.task_owner = {:company => {company: @company, role: :CA}}
      @task_all_ca.save

      @task_cc = FactoryGirl.create(:task)
      @task_cc.task_owner = {:user => @company_contact1}
      @task_cc.save
      puts @company_contact1
      @task_all_cc = FactoryGirl.create(:task)
      @task_all_cc.task_owner = {:company => {company: @company, role: :CC}}
      @task_all_cc.save
    end
    it 'job seeker user' do
      expect(Task.find_by_owner_user @job_seeker).to eq @task_js
    end
    it 'job developer user' do
      expect(Task.find_by_owner_user @job_developer1).to eq [@task_jd, @task_all_jd]
    end
    it 'case manager user' do
      expect(Task.find_by_owner_user @case_manager1).to eq [@task_cm, @task_all_cm]
    end
    it 'agency admin user' do
      expect(Task.find_by_owner_user @agency_admin1).to eq [@task_aa, @task_all_aa]
    end
    it 'company admin user' do
      expect(Task.find_by_owner_user @company_admin1).to eq [@task_ca, @task_all_ca]
    end
    it 'company contact user' do
      expect(Task.find_by_owner_user @company_contact1).to eq [@task_cc, @task_all_cc]
    end
  end
end
