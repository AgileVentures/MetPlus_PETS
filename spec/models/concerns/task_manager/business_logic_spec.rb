require 'rails_helper'
class TaskTester
  include TaskManager::TaskManager
  include TaskManager::BusinessLogic
end

RSpec.describe TaskManager::BusinessLogic do
  describe 'No Case Manager Assigned to Job Seeker' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
    end
    describe '#new_js_unassigned_cm_task' do
      subject {TaskTester.new_js_unassigned_cm_task @job_seeker, @agency}
      it('owner is agency admin'){expect(subject.task_owner).to eq([@agency_admin])}
      it('target job seeker'){expect(subject.target).to eq(@job_seeker)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:need_case_manager)}
    end
  end
  describe 'No Job Developer Assigned to Job Seeker' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
    end
    describe '#new_js_unassigned_jd_task' do
      subject {TaskTester.new_js_unassigned_jd_task @job_seeker, @agency}
      it('owner is agency admin'){expect(subject.task_owner).to eq([@agency_admin])}
      it('target job seeker'){expect(subject.target).to eq(@job_seeker)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:need_job_developer)}
    end
  end
  describe 'Job Seeker registration' do
    before :each do
      @job_seeker = FactoryGirl.create(:job_seeker)
      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryGirl.create(:agency)

      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
    end
    describe '#new_js_registration_task' do
      subject {TaskTester.new_js_registration_task @job_seeker, @agency}
      it('two tasks created'){expect(subject.size).to be 2}
      describe 'check first task' do
        it('check type'){expect(subject[0].task_type.to_sym).to eq(:need_job_developer)}
        it('owner is agency admin'){expect(subject[0].task_owner).to eq([@agency_admin])}
        it('target job seeker'){expect(subject[0].target).to eq(@job_seeker)}
      end
      describe 'check second task' do
        it('check type'){expect(subject[1].task_type.to_sym).to eq(:need_case_manager)}
        it('owner is agency admin'){expect(subject[1].task_owner).to eq([@agency_admin])}
        it('target job seeker'){expect(subject[1].target).to eq(@job_seeker)}
      end
    end
  end
  describe 'Review company registration' do
    before :each do
      @agency = FactoryGirl.create(:agency)
      @company = FactoryGirl.create(:company, agencies: [@agency])

      @aa_role = FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency_admin = FactoryGirl.create(:agency_person, :agency => @agency, :agency_roles => [@aa_role])
    end
    describe '#new_review_company_registration_task' do
      subject {TaskTester.new_review_company_registration_task @company, @agency}
      it('owner is agency admin'){expect(subject.task_owner).to eq([@agency_admin])}
      it('target company'){expect(subject.target).to eq(@company)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:company_registration)}
    end
  end

  describe 'Review job application' do
    let(:job_seeker)     { FactoryGirl.create(:job_seeker) }
    let(:company)        { FactoryGirl.create(:company) }
    let(:company_admin)  { FactoryGirl.create(:company_admin, company: company) }
    let(:job)            { FactoryGirl.create(:job, company: company,
                                              company_person: company_admin) }

    describe '#new_review_job_application_task' do
      subject {TaskTester.new_review_job_application_task job, company}
      it('owner is company admin'){expect(subject.task_owner).to eq([company_admin])}
      it('target application'){expect(subject.target).to eq(job)}
      it('check type'){expect(subject.task_type.to_sym).to eq(:job_application)}
    end
  end

end
