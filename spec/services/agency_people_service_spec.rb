require 'rails_helper'
require 'byebug'

RSpec.describe AgencyPeopleService, type: :model do
  let!(:agency)       { FactoryGirl.create(:agency) }
  let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_seeker)    { FactoryGirl.create(:job_seeker) }
  let(:service)       { AgencyPeopleService.new }

  describe 'assign_to_job_seeker' do
    before(:each) do
      allow(Event).to receive(:create)
    end

    context 'when assign a job developer' do
      context 'on success' do
        before(:each) do
          service.assign_to_job_seeker(
            job_seeker, 
            :JD, 
            job_developer)
        end

        it 'assigns job developer to job seeker' do
          expect(
            JobSeeker.find(job_seeker.id)
              .agency_relations.first.agency_person
          ).to eq job_developer
        end
      end
      
      context 'when agency person is not a job developer' do
        it 'raise NotAJobDeveloper exception' do
          expect{service.assign_to_job_seeker(
            job_seeker, 
            :JD, 
            case_manager)}.to raise_error(AgencyPeopleService::NotAJobDeveloper)
        end
      end
    end

    context 'when assign a case manager' do
      context 'on success' do
        before(:each) do
          service.assign_to_job_seeker(
            job_seeker, 
            :CM, 
            case_manager)
        end

        it 'assigns case manager to job seeker' do
          expect(
            JobSeeker.find(job_seeker.id)
              .agency_relations.first.agency_person
          ).to eq case_manager
        end
      end

      context 'when agency person is not a case manager' do
        it 'raise NotACaseManager exception' do
          expect{service.assign_to_job_seeker(
            job_seeker, 
            :CM, 
            job_developer)}.to raise_error(AgencyPeopleService::NotACaseManager)
        end
      end
    end

    context 'when assign a different role' do
      it 'raise InvalidRole exception' do
          expect{service.assign_to_job_seeker(
            job_seeker, 
            :AA,
            case_manager
          )}.to raise_error(AgencyPeopleService::InvalidRole)
      end
    end
  end
end