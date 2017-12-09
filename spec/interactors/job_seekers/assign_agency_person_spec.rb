require 'rails_helper'

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe JobSeekers::AssignAgencyPerson do
  let!(:agency)       { FactoryBot.create(:agency) }
  let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryBot.create(:job_seeker) }
  let(:service)       { JobSeekers::AssignAgencyPerson.new }

  describe '#call' do
    before(:each) do
      allow(Event).to receive(:create)
    end

    context 'when assign a job developer' do
      context 'on success' do
        context 'when is self assigned' do
          before(:each) do
            TestTaskHelper.new_js_unassigned_jd_task(job_seeker, agency)
            service.call(
              job_seeker,
              :JD,
              job_developer
            )
          end

          it 'assigns job developer to job seeker' do
            expect(
              JobSeeker.find(job_seeker.id)
                .agency_relations.first.agency_person
            ).to eq job_developer
          end

          it 'creates event JD_SELF_ASSIGN_JS' do
            expect(Event).to have_received(:create)
              .with(
                :JD_SELF_ASSIGN_JS,
                have_attributes(
                  job_seeker: job_seeker,
                  agency_person: job_developer
                )
              )
          end

          it 'completes need_job_developer Task' do
            expect(Task.agency_tasks(job_developer).length).to be 1
            expect(Task.agency_tasks(job_developer).first.status)
              .to eq TaskManager::TaskManager::STATUS[:DONE]
          end
        end

        context 'when is assigned by agency admin' do
          before(:each) do
            TestTaskHelper.new_js_unassigned_jd_task(job_seeker, agency)
            service.call(
              job_seeker,
              :JD,
              job_developer,
              false
            )
          end

          it 'assigns job developer to job seeker' do
            expect(
              JobSeeker.find(job_seeker.id)
                .agency_relations.first.agency_person
            ).to eq job_developer
          end

          it 'creates event JD_ASSIGNED_JS' do
            expect(Event).to have_received(:create)
              .with(
                :JD_ASSIGNED_JS,
                have_attributes(
                  job_seeker: job_seeker,
                  agency_person: job_developer
                )
              )
          end

          it 'completes need_job_developer Task' do
            expect(Task.agency_tasks(job_developer).length).to be 1
            expect(Task.agency_tasks(job_developer).first.status)
              .to eq TaskManager::TaskManager::STATUS[:DONE]
          end
        end
      end

      context 'when agency person is not a job developer' do
        it 'raise NotAJobDeveloper exception' do
          expect do
            service.call(
              job_seeker,
              :JD,
              case_manager
            )
          end.to raise_error(JobSeekers::AssignAgencyPerson::NotAJobDeveloper)
        end
      end
    end

    context 'when assign a case manager' do
      context 'on success' do
        before(:each) do
          TestTaskHelper.new_js_unassigned_cm_task(job_seeker, agency)
        end
        context 'when is self assigned' do
          before(:each) do
            service.call(
              job_seeker,
              :CM,
              case_manager
            )
          end

          it 'assigns case manager to job seeker' do
            expect(
              JobSeeker.find(job_seeker.id)
                .agency_relations.first.agency_person
            ).to eq case_manager
          end

          it 'creates event CM_SELF_ASSIGN_JS' do
            expect(Event).to have_received(:create)
              .with(
                :CM_SELF_ASSIGN_JS,
                have_attributes(
                  job_seeker: job_seeker,
                  agency_person: case_manager
                )
              )
          end

          it 'completes need_case_manager Task' do
            expect(Task.agency_tasks(case_manager).length).to be 1
            expect(Task.agency_tasks(case_manager).first.status)
              .to eq TaskManager::TaskManager::STATUS[:DONE]
          end
        end
        context 'when is assigned by agency admin' do
          before(:each) do
            service.call(
              job_seeker,
              :CM,
              case_manager,
              false
            )
          end

          it 'assigns case manager to job seeker' do
            expect(
              JobSeeker.find(job_seeker.id)
                .agency_relations.first.agency_person
            ).to eq case_manager
          end

          it 'creates event CM_ASSIGNED_JS' do
            expect(Event).to have_received(:create)
              .with(
                :CM_ASSIGNED_JS,
                have_attributes(
                  job_seeker: job_seeker,
                  agency_person: case_manager
                )
              )
          end

          it 'completes need_case_manager Task' do
            expect(Task.agency_tasks(case_manager).length).to be 1
            expect(Task.agency_tasks(case_manager).first.status)
              .to eq TaskManager::TaskManager::STATUS[:DONE]
          end
        end
      end

      context 'when agency person is not a case manager' do
        it 'raise NotACaseManager exception' do
          expect do
            service.call(
              job_seeker,
              :CM,
              job_developer
            )
          end.to raise_error(JobSeekers::AssignAgencyPerson::NotACaseManager)
        end
      end
    end

    context 'when assign a different role' do
      it 'raise InvalidRole exception' do
        expect do
          service.call(
            job_seeker,
            :AA,
            case_manager
          )
        end.to raise_error(JobSeekers::AssignAgencyPerson::InvalidRole)
      end

      it 'does not create an event' do
        expect do
          service.call(
            job_seeker,
            :AA,
            case_manager
          )
        end
        expect(Event).not_to have_received(:create)
      end
    end
  end
end
