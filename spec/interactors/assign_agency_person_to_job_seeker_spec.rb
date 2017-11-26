require 'rails_helper'
class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe AssignAgencyPersonToJobSeeker do
  let!(:agency)       { FactoryGirl.create(:agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryGirl.create(:job_seeker) }
  let(:service)       { AssignAgencyPersonToJobSeeker.new }

  describe '#call' do
    before(:each) do
      allow(Event).to receive(:create)
    end

    context 'when assign a job developer' do
      context 'on success' do
        context 'when a single job seeker is provided' do
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

        context 'when a list of job seekers is provided' do
          before(:each) do
            TestTaskHelper.new_js_unassigned_jd_task(job_seeker, agency)
            service.call(
              [job_seeker],
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
      end

      context 'when agency person is not a job developer' do
        it 'raise NotAJobDeveloper exception' do
          expect do
            service.call(
              job_seeker,
              :JD,
              case_manager
            )
          end.to raise_error(AssignAgencyPersonToJobSeeker::NotAJobDeveloper)
        end
      end
    end

    context 'when assign a case manager' do
      context 'on success' do
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
      end

      context 'when agency person is not a case manager' do
        it 'raise NotACaseManager exception' do
          expect do
            service.call(
              job_seeker,
              :CM,
              job_developer
            )
          end.to raise_error(AssignAgencyPersonToJobSeeker::NotACaseManager)
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
        end.to raise_error(AssignAgencyPersonToJobSeeker::InvalidRole)
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
