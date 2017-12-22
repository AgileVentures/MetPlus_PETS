require 'rails_helper'
RSpec.describe AgencyPeople::AssignNewJobSeekers do
  describe '#call' do
    let!(:agency)       { FactoryBot.create(:agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }
    let(:adam)          { FactoryBot.create(:job_seeker, first_name: 'Adam') }
    let(:jane)          { FactoryBot.create(:job_seeker, first_name: 'Jane') }
    let(:tom)           { FactoryBot.create(:job_seeker, first_name: 'Tom') }
    let(:julie)         { FactoryBot.create(:job_seeker, first_name: 'Julie') }
    let(:sam)           { FactoryBot.create(:job_seeker, first_name: 'Sam') }
    let(:interactor)    { AgencyPeople::AssignNewJobSeekers.new }
    let!(:assign_agency_person_mock) { instance_double('JobSeekers::AssignAgencyPerson') }

    before(:each) do
      allow(JobSeekers::AssignAgencyPerson)
        .to receive(:new).and_return(assign_agency_person_mock)
      allow(assign_agency_person_mock)
        .to receive(:call)
    end

    context 'when the agency person is a Job Developer' do
      context 'when no new job seekers were added' do
        before(:each) do
          sam.assign_job_developer(job_developer, agency)
          adam.assign_job_developer(job_developer, agency)
          tom.assign_job_developer(job_developer, agency)
          julie.assign_job_developer(job_developer, agency)

          interactor.call([sam, adam, tom, julie], :JD, job_developer)
        end

        it 'does not invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).not_to have_received(:call)
        end
      end

      context 'when new job seekers is added' do
        before(:each) do
          sam.assign_job_developer(job_developer, agency)
          adam.assign_job_developer(job_developer, agency)
          tom.assign_job_developer(job_developer, agency)

          interactor.call([sam, adam, tom, julie, jane], :JD, job_developer)
        end

        it 'does invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).to have_received(:call).twice
        end
      end

      context 'when job seekers are deleted' do
        before(:each) do
          sam.assign_job_developer(job_developer, agency)
          adam.assign_job_developer(job_developer, agency)
          tom.assign_job_developer(job_developer, agency)

          interactor.call([sam], :JD, job_developer)
        end

        it 'only sam is left' do
          expect(AgencyPerson.find(job_developer.id)
                            .agency_relations.count).to eql(1)
          expect(AgencyPerson.find(job_developer.id)
                            .agency_relations
                            .first.job_seeker).to eql(sam)
        end

        it 'does invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).not_to have_received(:call)
        end
      end
    end
    context 'when the agency person is a Case Manager' do
      context 'when no new job seekers were added' do
        before(:each) do
          sam.assign_case_manager(case_manager, agency)
          adam.assign_case_manager(case_manager, agency)
          tom.assign_case_manager(case_manager, agency)
          julie.assign_case_manager(case_manager, agency)

          interactor.call([sam, adam, tom, julie], :CM, case_manager)
        end

        it 'does not invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).not_to have_received(:call)
        end
      end

      context 'when new job seekers is added' do
        before(:each) do
          sam.assign_case_manager(case_manager, agency)
          adam.assign_case_manager(case_manager, agency)
          tom.assign_case_manager(case_manager, agency)

          interactor.call([sam, adam, tom, julie, jane], :CM, case_manager)
        end

        it 'does invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).to have_received(:call).twice
        end
      end

      context 'when job seekers are deleted' do
        before(:each) do
          sam.assign_case_manager(case_manager, agency)
          adam.assign_case_manager(case_manager, agency)
          tom.assign_case_manager(case_manager, agency)

          interactor.call([sam], :CM, case_manager)
        end

        it 'only sam is left' do
          expect(AgencyPerson.find(case_manager.id)
                            .agency_relations.count).to eql(1)
          expect(AgencyPerson.find(case_manager.id)
                            .agency_relations
                            .first.job_seeker).to eql(sam)
        end

        it 'does invoke JobSeekers::AssignAgencyPerson' do
          expect(assign_agency_person_mock).not_to have_received(:call)
        end
      end
    end
  end
end
