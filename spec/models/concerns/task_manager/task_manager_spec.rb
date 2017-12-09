require 'rails_helper'
class TaskTester
  include TaskManager::TaskManager
end
include ServiceStubHelpers::Cruncher

RSpec.describe TaskManager::TaskManager do
  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

  describe 'Class methods' do
    before :each do
      @job_seeker = FactoryBot.create(:job_seeker)
      @jd_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @cm_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:CM])
      @aa_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:AA])
      @agency = FactoryBot.create(:agency)

      @job_developer = FactoryBot.create(
        :agency_person,
        agency_roles: [@jd_role]
      )
      @job_developer1 = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@jd_role]
      )
      @job_developer2 = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@jd_role]
      )

      @case_manager = FactoryBot.create(
        :agency_person,
        agency_roles: [@cm_role]
      )
      @case_manager1 = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@cm_role]
      )
      @case_manager2 = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@cm_role]
      )

      @agency_admin = FactoryBot.create(:agency_person, agency_roles: [@aa_role])
      @agency_admin1 = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@aa_role]
      )

      @cm_and_jd = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@cm_role, @jd_role]
      )

      @cc_role = FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CC])
      @ca_role = FactoryBot.create(:company_role, role: CompanyRole::ROLE[:CA])

      @company = FactoryBot.create(:company)
      @company1 = FactoryBot.create(:company)
      @company_contact = FactoryBot.create(
        :company_person,
        company: @company1,
        company_roles: [@cc_role]
      )
      @company_contact1 = FactoryBot.create(
        :company_person,
        company: @company,
        company_roles: [@cc_role]
      )
      @company_contact2 = FactoryBot.create(
        :company_person,
        company: @company,
        company_roles: [@cc_role]
      )

      @company_admin = FactoryBot.create(
        :company_person,
        company: @company1,
        company_roles: [@ca_role]
      )
      @company_admin1 = FactoryBot.create(
        :company_person,
        company: @company,
        company_roles: [@ca_role]
      )
      @job = FactoryBot.create(:job)
      @job_application = FactoryBot.create(
        :job_application,
        job: @job,
        job_seeker: @job_seeker
      )
    end
    describe '#create_task' do
      describe 'Task to specific JD with job as target' do
        subject do
          TaskTester.create_task({ user: @job_developer2 }, 'simple', @job_application)
        end
        it('check owner') { expect(subject.task_owner).to eq @job_developer2 }
        it('check target') { expect(subject.target).to eq @job_application }
      end
      describe 'Task to all JD with JS as target' do
        subject do
          TaskTester.create_task(
            { agency: { agency: @agency, role: :JD } },
            'simple',
            @job_seeker
          )
        end
        it('check owner') do
          expect(subject.task_owner)
            .to contain_exactly(@job_developer1, @job_developer2, @cm_and_jd)
        end
        it('check target') { expect(subject.target).to eq @job_seeker }
      end
      describe 'Task to all CM with JS and Company as target' do
        subject do
          TaskTester.create_task(
            { agency: { agency: @agency, role: :CM } },
            'simple',
            @job_seeker,
            @company
          )
        end
        it('check owner') do
          expect(subject.task_owner)
            .to contain_exactly(@case_manager1, @case_manager2, @cm_and_jd)
        end
        it('check target') { expect(subject.target).to eq @job_seeker }
        it('check company') { expect(subject.company).to eq @company }
      end
      describe 'Task to all CA with JS and Job Application as target' do
        subject do
          TaskTester.create_task(
            { company: { company: @company, role: :CA } },
            'simple',
            @job_seeker,
            @job_application
          )
        end
        it('check owner') { expect(subject.task_owner).to eq [@company_admin1] }
        it('check target') { expect(subject.target).to eq @job_seeker }
        it('check job_application') do
          expect(subject.job_application).to eq @job_application
        end
      end
      describe 'Task to all CC with JS, Company and Job as target' do
        subject do
          TaskTester.create_task(
            { company: { company: @company, role: :CC } },
            'simple',
            @job_seeker,
            @job,
            @company
          )
        end
        it('check owner') do
          expect(subject.task_owner)
            .to contain_exactly(@company_contact1, @company_contact2)
        end
        it('check target') { expect(subject.target).to eq @job_seeker }
        it('check job') { expect(subject.job).to eq @job }
        it('check company') { expect(subject.company).to eq @company }
      end
    end
  end
  describe 'Instance methods' do
    before :each do
      @jd_role = FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD])
      @agency = FactoryBot.create(:agency)

      @job_developer = FactoryBot.create(
        :agency_person,
        agency: @agency,
        agency_roles: [@jd_role]
      )
      @job = FactoryBot.create(:job)
    end
    describe '#assign' do
      subject { TaskTester.create_task({ user: @job_developer }, 'simple', @job) }
      it('Check status change') do
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:NEW])
        subject.assign @job_developer
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:ASSIGNED])
      end
      it('Invalid status change') do
        subject.status = TaskManager::TaskManager::STATUS[:WIP]
        expect { subject.assign @job_developer }
          .to raise_error(ArgumentError)
          .with_message 'Task need to be in created state'
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:WIP])
      end
    end
    describe '#work_in_progress' do
      subject { TaskTester.create_task({ user: @job_developer }, 'simple', @job) }
      it('Check status change') do
        subject.assign @job_developer
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:ASSIGNED])
        subject.work_in_progress
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:WIP])
      end
      it('Invalid status change') do
        subject.status = TaskManager::TaskManager::STATUS[:DONE]
        expect { subject.work_in_progress }
          .to raise_error(ArgumentError)
          .with_message 'Task need to be in assigned state'
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:DONE])
      end
    end
    describe '#complete' do
      subject { TaskTester.create_task({ user: @job_developer }, 'simple', @job) }
      it('Check status change') do
        subject.assign @job_developer
        subject.work_in_progress
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:WIP])
        subject.complete
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:DONE])
      end
      it('Invalid status change') do
        subject.status = TaskManager::TaskManager::STATUS[:NEW]
        expect { subject.complete }
          .to raise_error(ArgumentError)
          .with_message 'Task need to be in work in progress state'
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:NEW])
      end
    end
    describe '#force_close' do
      subject { TaskTester.create_task({ user: @job_developer }, 'simple', @job) }
      it('Check status change') do
        subject.assign @job_developer
        subject.force_close
        expect(subject.status).to eq(TaskManager::TaskManager::STATUS[:DONE])
      end
    end
  end
end
