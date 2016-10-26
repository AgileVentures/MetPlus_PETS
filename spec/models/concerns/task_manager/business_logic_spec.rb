require 'rails_helper'
class TaskTester
  include TaskManager::TaskManager
  include TaskManager::BusinessLogic
end
include ServiceStubHelpers::Cruncher

RSpec.describe TaskManager::BusinessLogic do
  describe 'No Case Manager Assigned to Job Seeker' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
      @case_mgr1 = FactoryGirl.create(:case_manager, agency: @agency)
      @case_mgr2 = FactoryGirl.create(:case_manager, agency: @agency)
    end
    describe '#new_js_unassigned_cm_task' do
      subject {TaskTester.new_js_unassigned_cm_task @job_seeker, @agency}
      it('owner is agency admin'){expect(subject.task_owner).to eq([@agency_admin])}
      it('target job seeker'){expect(subject.target).to eq(@job_seeker)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:need_case_manager)}
      it 'has assignable list of all case managers in the agency' do
        expect(subject.assignable_list).to include(@case_mgr1, @case_mgr2)
      end
    end
  end
  describe 'No Job Developer Assigned to Job Seeker' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
      @job_dev1  = FactoryGirl.create(:job_developer, agency: @agency)
      @job_dev2  = FactoryGirl.create(:job_developer, agency: @agency)
    end
    describe '#new_js_unassigned_jd_task' do
      subject {TaskTester.new_js_unassigned_jd_task @job_seeker, @agency}
      it('owner is agency admin'){expect(subject.task_owner).to eq([@agency_admin])}
      it('target job seeker'){expect(subject.target).to eq(@job_seeker)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:need_job_developer)}
      it 'has assignable list of all job developers in the agency' do
        expect(subject.assignable_list).to include(@job_dev1, @job_dev2)
      end
    end
  end
  describe 'Job Seeker registration' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
      @case_mgr1 = FactoryGirl.create(:case_manager, agency: @agency)
      @case_mgr2 = FactoryGirl.create(:case_manager, agency: @agency)
      @job_dev1  = FactoryGirl.create(:job_developer, agency: @agency)
      @job_dev2  = FactoryGirl.create(:job_developer, agency: @agency)

    end
    describe '#new_js_registration_task' do
      subject {TaskTester.new_js_registration_task @job_seeker, @agency}
      it('two tasks created'){expect(subject.size).to be 2}
      describe 'check need_job_developer task' do
        it('check type'){expect(subject[0].task_type.to_sym).to eq(:need_job_developer)}
        it('owner is agency admin'){expect(subject[0].task_owner).to eq([@agency_admin])}
        it('target job seeker'){expect(subject[0].target).to eq(@job_seeker)}
        it 'has assignable list of all job developers in the agency' do
          expect(subject[0].assignable_list).to include(@job_dev1, @job_dev2)
        end
      end
      describe 'check need_case_manager task' do
        it('check type'){expect(subject[1].task_type.to_sym).to eq(:need_case_manager)}
        it('owner is agency admin'){expect(subject[1].task_owner).to eq([@agency_admin])}
        it('target job seeker'){expect(subject[1].target).to eq(@job_seeker)}
        it 'has assignable list of all case managers in the agency' do
          expect(subject[1].assignable_list).to include(@case_mgr1, @case_mgr2)
        end
      end
    end
  end
  describe 'Review company registration' do
    let(:agency)         { FactoryGirl.create(:agency) }
    let(:company)        { FactoryGirl.create(:company, agencies: [agency]) }
    let!(:agency_admin)  { FactoryGirl.create(:agency_admin, agency: agency) }
    let!(:agency_admin2) { FactoryGirl.create(:agency_admin, agency: agency) }

    describe '#new_review_company_registration_task' do
      subject {TaskTester.new_review_company_registration_task company, agency}
      it 'owner is agency admins' do
        expect(subject.task_owner).to match_array [agency_admin, agency_admin2]
      end
      it('target company'){expect(subject.target).to eq(company)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:company_registration)}
      it 'has assignable list of all admins in the agency' do
        expect(subject.assignable_list).to include(agency_admin, agency_admin2)
      end
    end
  end

  describe 'Review job application' do
    let(:job_seeker)     { FactoryGirl.create(:job_seeker) }
    let(:company)        { FactoryGirl.create(:company) }
    let(:company_admin)  { FactoryGirl.create(:company_admin, company: company) }
    let(:company_cc1)    { FactoryGirl.create(:company_contact, company: company) }
    let(:company_cc2)    { FactoryGirl.create(:company_contact, company: company) }
    let(:job)            { FactoryGirl.create(:job, company: company,
                                              company_person: company_admin) }

    describe '#new_review_job_application_task' do
      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
      end

      subject {TaskTester.new_review_job_application_task job, company}
      it('owner is company admin'){expect(subject.task_owner).to eq([company_admin])}
      it('target application'){expect(subject.target).to eq(job)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:job_application)}
      it 'has assignable list of everyone in the company' do
        expect(subject.assignable_list).to include(company_admin, company_cc1, company_cc2)
      end
    end
  end

end
