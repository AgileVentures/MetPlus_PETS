require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestJobApplicationsViewerClass < ApplicationController
  include JobApplicationsViewer
end

RSpec.describe TestJobApplicationsViewerClass do
  describe '#display_job_application' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:company) { FactoryGirl.create(:company, agencies: [agency]) }
    let(:company1) { FactoryGirl.create(:company, agencies: [agency]) }
    let(:company_admin) { FactoryGirl.create(:company_admin, company: company) }
    let(:job_seeker1) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker2) { FactoryGirl.create(:job_seeker) }
    let(:job_seeker3) { FactoryGirl.create(:job_seeker) }
    let(:job) { FactoryGirl.create(:job, company: company) }
    let(:job1) { FactoryGirl.create(:job, company: company) }
    let(:job2) { FactoryGirl.create(:job, company: company) }
    let(:company1_job1) { FactoryGirl.create(:job, company: company1) }

    let!(:stub) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
    end

    describe 'When Company Admin check applications from a specific JS' do
      before(:each) do
        sign_in(company_admin.user)
      end

      context 'When Job Seeker did not apply to the company' do
        it 'return empty list' do
          job_application = FactoryGirl.create(:job_application,
                                               job_seeker: job_seeker1,
                                               job: company1_job1)
          
          expect(subject.display_job_applications('job_seeker-company-person',
                                                  job_seeker1.id)).to eq([])
        end
      end

      context 'When Job Seeker applied to one Job' do
        it 'return one job application' do
          job_application = FactoryGirl.create(:job_application,
                                               job_seeker: job_seeker1,
                                               job: job)

          expect(subject
            .display_job_applications('job_seeker-company-person',
                                      job_seeker1.id))
            .to eq([job_application])
        end
      end

      context 'When JS applied to multiple jobs in different companies' do
        let!(:job_application) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job
        ) }
        let!(:job_application1) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job1
        ) }
        let!(:job_application2) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job2
        ) }

        context 'When no Application per page restriction is set' do
          it 'return 3 job applications' do
            expect(subject
              .display_job_applications('job_seeker-company-person',
                                        job_seeker1.id))
              .to include(job_application,
                          job_application1,
                          job_application2)
          end
        end

        context 'When restrict 1 Applications per page' do
          it 'return 1 job application' do
            result = subject.display_job_applications('job_seeker-company-person',
                                             job_seeker1.id,
                                             1)

            expect(result.size).to be(1)
            expect(result).to include(job_application)
          end
        end
      end
    end

    describe 'When retrieving applications for Job Seeker' do
      context 'When never applied' do
        it 'return empty list' do
          expect(subject
            .display_job_applications('job_seeker-default',
                                      job_seeker1.id)).to eq([])
        end
      end

      context 'When applied to one job' do
        it 'return one job application' do
          job_application = FactoryGirl.create(:job_application,
                                               job_seeker: job_seeker1,
                                               job: job)

          expect(subject
            .display_job_applications('job_seeker-default',
                                      job_seeker1.id))
            .to eq([job_application])
        end
      end

      context 'When applied to multiple jobs' do
        let!(:job_application) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job
        ) }
        let!(:job_application1) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job1
        ) }
        let!(:job_application2) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: company1_job1
        ) }

        context 'When no Application per page restriction is set' do
          it 'return 3 job applications' do
            expect(subject.display_job_applications('job_seeker-default',
                                                    job_seeker1.id))
              .to include(job_application,
                          job_application1,
                          job_application2)
          end
        end

        context 'When restrincting 1 applications per page' do
          it 'return 1 job application' do
            result = subject.display_job_applications('job_seeker-default',
                                               job_seeker1.id,
                                               1)

            expect(result.size).to be(1)
            expect(result.count).to be(3)
            expect(result).to include(job_application)
          end
        end
      end
    end

    describe 'Application to a Job by JS related to the current JD' do
      before(:each) do
        sign_in(job_developer.user)
      end

      context 'When no Job Seeker applicated' do
        it 'return empty list' do
          expect(subject
            .display_job_applications('job-job-developer',
                                      job.id)).to eq([])
        end
      end

      context 'When 1 Job Seeker applied' do
        it 'return one job application' do
          job_seeker1.assign_job_developer(job_developer, agency)
          job_application = FactoryGirl.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )

          expect(subject
            .display_job_applications('job-job-developer',
                                      job.id))
            .to eq([job_application])
        end
      end

      context 'When 2 Job Seekers applied' do
        before(:each) do
          job_seeker1.assign_job_developer(job_developer, agency)
          job_seeker2.assign_job_developer(job_developer, agency)
        end

        let!(:job_application) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker1,
          job: job
        ) }

        let!(:job_application1) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker2,
          job: job
        ) }

        let!(:job_application2) { FactoryGirl.create(
          :job_application,
          job_seeker: job_seeker3,
          job: job
        ) }

        context 'When no Application per page restriction is set' do
          it 'return 2 job applications' do
            expect(subject
              .display_job_applications('job-job-developer',
                                        job.id))
              .to include(job_application,
                          job_application1)
          end
        end

        context 'When restricting 1 applications per page' do
          it 'return 1 job application' do
            result = subject.display_job_applications('job-job-developer', job.id, 1)

            expect(result.size).to be(1)
            expect(result.count).to be(2)
            expect(result).to include(job_application)
          end
        end
      end
    end

    describe 'When a Company person retrieve applications to a Job' do
      context 'When no Job Seeker applied' do
        it 'return empty list' do
          expect(subject
            .display_job_applications('job-company-person',
                                      job.id)).to eq([])
        end
      end

      context 'When 1 Job Seeker applied' do
        it 'return one job application' do
          job_application = FactoryGirl.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )

          expect(subject
            .display_job_applications('job-company-person',
                                      job.id))
            .to eq([job_application])
        end
      end

      context 'When 2 Job Seekers applied' do
        let!(:job_application) {
          FactoryGirl.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
        }

        let!(:job_application1) {
          FactoryGirl.create(
            :job_application,
            job_seeker: job_seeker2,
            job: job
          )
        }

        let!(:job_application2) {
          FactoryGirl.create(
            :job_application,
            job_seeker: job_seeker3,
            job: job1
          )
        }

        context 'When no Application per page restriction is set' do
          it 'return 2 job applications' do
            expect(subject
              .display_job_applications('job-company-person',
                                        job.id))
              .to include(job_application,
                          job_application1)
          end
        end

        context 'When restricting 1 applications per page' do
          it 'returns first job application' do
            result = subject.display_job_applications('job-company-person',
                                             job.id,
                                             1)

            expect(result.size).to eq(1) # Records in this page
            expect(result.count).to eq(2) # Total records returned
            expect(result).to include(job_application)
          end
        end
      end
    end
  end
end
