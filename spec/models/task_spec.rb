require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe Task, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.create(:task)).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }

    it { is_expected.to have_db_column :owner_user_id }

    it { is_expected.to have_db_column :owner_agency_id }
    it { is_expected.to have_db_column :owner_agency_role }

    it { is_expected.to have_db_column :owner_company_id }
    it { is_expected.to have_db_column :owner_company_role }

    it { is_expected.to have_db_column :deferred_date}
    it { is_expected.to have_db_column :user_id}
    it { is_expected.to have_db_column :job_id}
    it { is_expected.to have_db_column :company_id}
  end
  describe 'Validators' do
    before :each do
      @company = FactoryGirl.build(:company)
      @agency = FactoryGirl.build(:agency)
      @user = FactoryGirl.build(:job_seeker)
    end
    describe 'errors' do
      subject {FactoryGirl.build(:task)}
      it 'no user set' do
        should_not allow_value({:user => nil}).for(:task_owner).with_message("need to be set")
      end
      it 'no company role' do
        should_not allow_value({:company => {company: @company, role: nil}}).for(:task_owner).with_message("no company role set")
      end
      it 'unkown company role' do
        should_not allow_value({:company => {company: @company, role: :INVALID}}).for(:task_owner).with_message("unknown company role")
      end
      it 'no agency role' do
        should_not allow_value({:agency => {agency: @agency, role: nil}}).for(:task_owner).with_message("no agency role set")
      end
      it 'unkown agency role' do
        should_not allow_value({:agency => {agency: @agency, role: :INVALID}}).for(:task_owner).with_message("unknown agency role")
      end
    end
    describe 'success' do
      subject {FactoryGirl.build(:task)}
      it 'user' do
        should allow_value({:user => @user}).for(:task_owner)
      end
      it 'company' do
        should allow_value({:company => {company: @company, role: :CC}}).for(:task_owner)
      end
      it 'agency' do
        should allow_value({:agency => {agency: @agency, role: :AA}}).for(:task_owner)
      end
    end
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


      @task = FactoryGirl.build(:task)
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
  describe 'Setting target of the task' do
    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create

      @job_seeker = FactoryGirl.create(:job_seeker)
      @jd_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @job_developer = FactoryGirl.create(:agency_person, :agency_roles => [@jd_role])

      @case_manager = FactoryGirl.create(:agency_person, :agency_roles => [@cm_role])

      @agency_admin = FactoryGirl.create(:agency_person, :agency_roles => [@aa_role])


      @cc_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ca_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company = FactoryGirl.create(:company)
      @company_contact = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@cc_role])


      @company_admin = FactoryGirl.create(:company_person, :company => @company1, :company_roles => [@ca_role])

      @job = FactoryGirl.create(:job)

      @task = FactoryGirl.build(:task)
    end
    it 'job seeker user' do
      @task.target = @job_seeker
      expect(@task.target).to eq @job_seeker
      expect(@task.person).to eq @job_seeker
    end
    it 'job seeker as a User' do
      @task.target = @job_seeker.user
      expect(@task.target).to eq @job_seeker
      expect(@task.person).to eq @job_seeker
    end
    it 'job developer user' do
      @task.target = @job_developer
      expect(@task.target).to eq @job_developer
      expect(@task.person).to eq @job_developer
    end
    it 'case manager user' do
      @task.target = @case_manager
      expect(@task.target).to eq @case_manager
      expect(@task.person).to eq @case_manager
    end
    it 'agency admin user' do
      @task.target = @agency_admin
      expect(@task.target).to eq @agency_admin
      expect(@task.person).to eq @agency_admin
    end
    it 'company admin user' do
      @task.target = @company_admin
      expect(@task.target).to eq @company_admin
      expect(@task.person).to eq @company_admin
    end
    it 'company contact user' do
      @task.target = @company_contact
      expect(@task.target).to eq @company_contact
      expect(@task.person).to eq @company_contact
    end
    it 'job' do
      @task.target = @job
      expect(@task.target).to eq @job
    end
    it 'company' do
      @task.target = @company
      expect(@task.target).to eq @company
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


      @task_js = FactoryGirl.create(:task, :task_owner => {:user => @job_seeker})
      @task_js_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @job_seeker})

      @task_jd = FactoryGirl.create(:task, :task_owner => {:user => @job_developer1})
      @task_jd_today = FactoryGirl.create(:task, :deferred_date => Date.today, :task_owner => {:user => @job_developer1})
      @task_jd_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @job_developer1})
      @task_all_jd = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :JD}})
      @task_all_jd_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:agency => {agency: @agency, role: :JD}})

      @task_cm = FactoryGirl.create(:task, :task_owner => {:user => @case_manager1})
      @task_cm_today = FactoryGirl.create(:task, :deferred_date => Date.today, :task_owner => {:user => @case_manager1})
      @task_cm_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @case_manager1})
      @task_all_cm = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :CM}})
      @task_all_cm_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:agency => {agency: @agency, role: :CM}})

      @task_aa = FactoryGirl.create(:task, :task_owner => {:user => @agency_admin1})
      @task_aa_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @agency_admin1})
      @task_all_aa = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :AA}})
      @task_all_aa_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:agency => {agency: @agency, role: :AA}})

      @task_ca = FactoryGirl.create(:task, :task_owner => {:user => @company_admin1})
      @task_ca_today = FactoryGirl.create(:task, :deferred_date => Date.today, :task_owner => {:user => @company_admin1})
      @task_ca_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @company_admin1})
      @task_all_ca = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CA}})
      @task_all_ca_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:company => {company: @company, role: :CA}})

      @task_cc = FactoryGirl.create(:task, :task_owner => {:user => @company_contact1})
      @task_cc_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:user => @company_contact1})
      @task_all_cc = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CC}})
      @task_all_cc_future = FactoryGirl.create(:task, :deferred_date => Date.today + 1, :task_owner => {:company => {company: @company, role: :CC}})
    end
    it 'job seeker user' do
      expect(Task.find_by_owner_user_open @job_seeker).to eq [@task_js]
    end
    it 'job developer user' do
      expect(Task.find_by_owner_user_open @job_developer1).to eq [@task_jd, @task_jd_today]
    end
    it 'case manager user' do
      expect(Task.find_by_owner_user_open @case_manager1).to eq [@task_cm, @task_cm_today]
    end
    it 'agency admin user' do
      expect(Task.find_by_owner_user_open @agency_admin1).to eq [@task_aa]
    end
    it 'company admin user' do
      expect(Task.find_by_owner_user_open @company_admin1).to eq [@task_ca, @task_ca_today]
    end
    it 'company contact user' do
      expect(Task.find_by_owner_user_open @company_contact1).to eq [@task_cc]
    end
  end
  describe 'Find all tasks for a owner' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @jd_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @job_developer = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@jd_role])

      @case_manager = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@cm_role])

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])

      @cc_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ca_role = FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company = FactoryGirl.create(:company)
      @company_contact = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@cc_role])


      @company_admin = FactoryGirl.create(:company_person, :company => @company, :company_roles => [@ca_role])


      @task_js_new = FactoryGirl.create(:task, :task_owner => {:user => @job_seeker})
      @task_js_new.assign @job_seeker
      @task_js_closed = FactoryGirl.create(:task, :task_owner => {:user => @job_seeker})
      @task_js_closed.assign @job_seeker
      @task_js_closed.work_in_progress
      @task_js_closed.complete

      @task_jd_new = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :JD}})
      @task_jd_new.assign @job_developer
      @task_jd_closed = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :JD}})
      @task_jd_closed.assign @job_developer
      @task_jd_closed.work_in_progress
      @task_jd_closed.complete

      @task_cm_new = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :CM}})
      @task_cm_new.assign @case_manager
      @task_cm_closed = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :CM}})
      @task_cm_closed.assign @case_manager
      @task_cm_closed.work_in_progress
      @task_cm_closed.complete

      @task_aa_new = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :AA}})
      @task_aa_new.assign @agency_admin
      @task_aa_closed = FactoryGirl.create(:task, :task_owner => {:agency => {agency: @agency, role: :AA}})
      @task_aa_closed.assign @agency_admin
      @task_aa_closed.work_in_progress
      @task_aa_closed.complete
      @task_aa_unassigned1 = FactoryGirl.create(:task,
                  :task_owner => {:agency => {agency: @agency, role: :AA}})
      @task_aa_unassigned2 = FactoryGirl.create(:task,
                  :task_owner => {:agency => {agency: @agency, role: :AA}})

      @task_ca_new = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CA}})
      @task_ca_new.assign @company_admin
      @task_ca_closed = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CA}})
      @task_ca_closed.assign @company_admin
      @task_ca_closed.work_in_progress
      @task_ca_closed.complete
      @task_ca_unassigned1 = FactoryGirl.create(:task,
                  :task_owner => {:company => {company: @company, role: :CA}})
      @task_ca_unassigned2 = FactoryGirl.create(:task,
                  :task_owner => {:company => {company: @company, role: :CA}})

      @task_cc_new = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CC}})
      @task_cc_new.assign @company_contact
      @task_cc_closed = FactoryGirl.create(:task, :task_owner => {:company => {company: @company, role: :CC}})
      @task_cc_closed.assign @company_contact
      @task_cc_closed.work_in_progress
      @task_cc_closed.complete
    end
    describe 'all new (unassigned) tasks for company/agency' do
      it 'company' do
        expect(Task.find_by_company_new @company_admin).
                    to match_array [@task_ca_unassigned1, @task_ca_unassigned2]
      end
      it 'agency' do
        expect(Task.find_by_agency_new @agency_admin).
                    to match_array [@task_aa_unassigned1, @task_aa_unassigned2]
      end
    end
    describe 'all open (assigned and incomplete) tasks for company/agency' do
      it 'company' do
        expect(Task.find_by_company_active @company_admin).
                    to match_array [@task_ca_new, @task_cc_new]
      end
      it 'agency' do
        expect(Task.find_by_agency_active @agency_admin).
                    to match_array [@task_jd_new, @task_cm_new, @task_aa_new]
      end
    end
    describe 'all closed tasks for company/agency' do
      it 'company' do
        expect(Task.find_by_company_closed @company_admin).
                    to match_array [@task_ca_closed, @task_cc_closed]
      end
      it 'agency' do
        expect(Task.find_by_agency_closed @agency_admin).
                    to match_array [@task_aa_closed, @task_jd_closed, @task_cm_closed]
      end
    end
    describe 'open tasks for assigned owner' do
      it 'job developer user' do
        expect(Task.find_by_owner_user_open @job_developer).to eq [@task_jd_new]
      end
      it 'case manager user' do
        expect(Task.find_by_owner_user_open @case_manager).to eq [@task_cm_new]
      end
      it 'agency admin user' do
        expect(Task.find_by_owner_user_open @agency_admin).to eq [@task_aa_new]
      end
      it 'company admin user' do
        expect(Task.find_by_owner_user_open @company_admin).to eq [@task_ca_new]
      end
      it 'company contact user' do
        expect(Task.find_by_owner_user_open @company_contact).to eq [@task_cc_new]
      end
    end
    describe 'closed tasks for assigned owner' do
      it 'job developer user' do
        expect(Task.find_by_owner_user_closed @job_developer).to eq [@task_jd_closed]
      end
      it 'case manager user' do
        expect(Task.find_by_owner_user_closed @case_manager).to eq [@task_cm_closed]
      end
      it 'agency admin user' do
        expect(Task.find_by_owner_user_closed @agency_admin).to eq [@task_aa_closed]
      end
      it 'company admin user' do
        expect(Task.find_by_owner_user_closed @company_admin).to eq [@task_ca_closed]
      end
      it 'company contact user' do
        expect(Task.find_by_owner_user_closed @company_contact).to eq [@task_cc_closed]
      end
    end
  end
end
