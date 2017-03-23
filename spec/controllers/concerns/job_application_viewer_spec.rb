require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestJobApplicationsViewerClass < ApplicationController
  include JobApplicationsViewer
end

RSpec.describe TestJobApplicationsViewerClass do
  describe '#display_job_application' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let(:agency_admin)  { FactoryGirl.create(:agency_admin, agency: agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:company)       { FactoryGirl.create(:company, agencies: [agency]) }
    let(:company1)       { FactoryGirl.create(:company, agencies: [agency]) }
    let(:company_admin) { FactoryGirl.create(:company_admin, company: company) }
    let(:cmpy_person)   { FactoryGirl.create(:company_contact, company: company) }
    let(:job_seeker1)   { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2)   { FactoryGirl.create(:job_seeker) }
    let(:job_seeker3)   { FactoryGirl.create(:job_seeker) }
    let(:job)           { FactoryGirl.create(:job, company: company) }
    let(:job1)           { FactoryGirl.create(:job, company: company) }
    let(:job2)           { FactoryGirl.create(:job, company: company) }
    let(:company1_job1)  { FactoryGirl.create(:job, company: company1) }
    let(:company1_job2)  { FactoryGirl.create(:job, company: company1) }

    let!(:stub) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
    end

    before(:each) do
      allow(subject).to receive(:pets_user).and_return(company_admin)
    end

    describe 'All applications from a JS to a specific company' do
      context 'Job seeker never applied to current company' do
        it 'return empty list' do
          expect(subject
           .display_job_applications('job_seeker-company-person',
                                    job_seeker1.id)).to eq([])
        end
      end
      context 'One Job Seeker applied' do
        before(:each) do
          @job_application = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job)
        end

        it 'return one job application' do
          expect(subject
           .display_job_applications('job_seeker-company-person',
                                     job_seeker1.id))
           .to eq([@job_application])
        end
      end
      context 'Job Seeker applied to multiple jobs' do
        before(:each) do
          @job_application = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job)
          @job_application1 = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job1)
          @job_application2 = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job2)
        end
        context 'using default restriction of applications per page' do
          it 'return 3 job applications' do
              expect(subject
               .display_job_applications('job_seeker-company-person',
                                         job_seeker1.id))
               .to include(@job_application,
                            @job_application1,
                            @job_application2)
          end
        end
        context 'restricting 1 applications per page' do
          let(:result) {subject
           .display_job_applications('job_seeker-company-person',
                                     job_seeker1.id, 1)}
          it 'return 1 job application' do
              expect(result.size).to be(1)
          end
          it 'return first job application' do
              expect(result).to include(@job_application)
          end
        end
      end
    end
    describe 'All applications for a job seeker' do
      context 'Job seeker never applied' do
        it 'return empty list' do
          expect(subject
           .display_job_applications('job_seeker-default',
                                    job_seeker1.id)).to eq([])
        end
      end
      context 'Job Seeker applied to one job' do
        before(:each) do
          @job_application = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job)
        end

        it 'return one job application' do
          expect(subject
           .display_job_applications('job_seeker-default',
                                     job_seeker1.id))
           .to eq([@job_application])
        end
      end
      context 'Job Seeker applied to multiple jobs' do
        before(:each) do
          @job_application = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job)
          @job_application1 = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => job1)
          @job_application2 = FactoryGirl.create(
            :job_application,
            :job_seeker => job_seeker1,
            :job => company1_job1)
        end
        context 'using default restriction of applications per page' do
          it 'return 3 job applications' do
              expect(subject
               .display_job_applications('job_seeker-default',
                                         job_seeker1.id))
               .to include(@job_application,
                            @job_application1,
                            @job_application2)
          end
        end
        context 'restricting 1 applications per page' do
          let(:result) {subject
           .display_job_applications('job_seeker-default',
                                     job_seeker1.id, 1)}
          it 'return 1 job application' do
              expect(result.size).to be(1)
          end
          it 'return first job application' do
              expect(result).to include(@job_application)
          end
        end
      end
    end
  end
end
