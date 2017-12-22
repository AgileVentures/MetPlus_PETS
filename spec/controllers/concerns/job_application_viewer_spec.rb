require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestJobApplicationsViewerClass < ApplicationController
  include JobApplicationsViewer
end

RSpec.describe TestJobApplicationsViewerClass do
  describe '#display_job_application' do
    let!(:agency) { FactoryBot.create(:agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:company) { FactoryBot.create(:company, agencies: [agency]) }
    let(:company1) { FactoryBot.create(:company, agencies: [agency]) }
    let(:company_admin) { FactoryBot.create(:company_admin, company: company) }
    let(:job_seeker1) { FactoryBot.create(:job_seeker) }
    let(:job_seeker2) { FactoryBot.create(:job_seeker) }
    let(:job_seeker3) { FactoryBot.create(:job_seeker) }
    let(:job) { FactoryBot.create(:job, company: company) }
    let(:job1) { FactoryBot.create(:job, company: company) }
    let(:job2) { FactoryBot.create(:job, company: company) }
    let(:company1_job1) { FactoryBot.create(:job, company: company1) }

    let!(:stub) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_job_update
    end

    describe 'When Company Admin check applications from a specific JS' do
      before(:each) do
        allow(subject).to receive(:pets_user).and_return(company_admin)
      end

      context 'When Job Seeker did not apply to the company' do
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: company1_job1
          )
        end

        it 'return empty list' do
          expect(subject.display_job_applications('job_seeker-company-person',
                                                  job_seeker1.id)).to eq([])
        end
      end

      context 'When Job Seeker applied to one Job' do
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
        end

        it 'return one job application' do
          expect(subject
            .display_job_applications('job_seeker-company-person',
                                      job_seeker1.id))
            .to eq([@job_application])
        end
      end

      context 'When JS applied to multiple jobs in different companies' do
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
          @job_application1 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job1
          )
          @job_application2 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job2
          )
        end

        context 'When no Application per page restriction is set' do
          it 'return 3 job applications' do
            expect(subject
              .display_job_applications('job_seeker-company-person',
                                        job_seeker1.id))
              .to include(@job_application,
                          @job_application1,
                          @job_application2)
          end
        end

        context 'When restrict 1 Applications per page' do
          let(:result) do
            subject.display_job_applications('job_seeker-company-person',
                                             job_seeker1.id,
                                             1)
          end

          it 'return 1 job application' do
            expect(result.size).to be(1)
          end

          it 'return first job application' do
            expect(result).to include(@job_application)
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
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
        end

        it 'return one job application' do
          expect(subject
            .display_job_applications('job_seeker-default',
                                      job_seeker1.id))
            .to eq([@job_application])
        end
      end

      context 'When applied to multiple jobs' do
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
          @job_application1 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job1
          )
          @job_application2 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: company1_job1
          )
        end

        context 'When no Application per page restriction is set' do
          it 'return 3 job applications' do
            expect(subject.display_job_applications('job_seeker-default',
                                                    job_seeker1.id))
              .to include(@job_application,
                          @job_application1,
                          @job_application2)
          end
        end

        context 'When restrincting 1 applications per page' do
          let(:result) do
            subject.display_job_applications('job_seeker-default',
                                             job_seeker1.id,
                                             1)
          end

          it 'return 1 job application' do
            expect(result.size).to be(1)
          end

          it 'found 3 job applications' do
            expect(result.count).to be(3)
          end

          it 'return first job application' do
            expect(result).to include(@job_application)
          end
        end
      end
    end

    describe 'Application to a Job by JS related to the current JD' do
      before(:each) do
        allow(subject).to receive(:pets_user).and_return(job_developer)
      end

      context 'When no Job Seeker applicated' do
        it 'return empty list' do
          expect(subject
            .display_job_applications('job-job-developer',
                                      job.id)).to eq([])
        end
      end

      context 'When 1 Job Seeker applied' do
        before(:each) do
          job_seeker1.assign_job_developer(job_developer, agency)
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
        end

        it 'return one job application' do
          expect(subject
            .display_job_applications('job-job-developer',
                                      job.id))
            .to eq([@job_application])
        end
      end

      context 'When 2 Job Seekers applied' do
        before(:each) do
          job_seeker1.assign_job_developer(job_developer, agency)
          job_seeker2.assign_job_developer(job_developer, agency)
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
          @job_application1 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker2,
            job: job
          )
          @job_application2 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker3,
            job: job
          )
        end

        context 'When no Application per page restriction is set' do
          it 'return 2 job applications' do
            expect(subject
              .display_job_applications('job-job-developer',
                                        job.id))
              .to include(@job_application,
                          @job_application1)
          end
        end

        context 'When restricting 1 applications per page' do
          let(:result) do
            subject.display_job_applications('job-job-developer',
                                             job.id,
                                             1)
          end
          it 'return 1 job application' do
            expect(result.size).to be(1)
          end

          it 'found 2 job applications' do
            expect(result.count).to be(2)
          end

          it 'return first job application' do
            expect(result).to include(@job_application)
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
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
        end

        it 'return one job application' do
          expect(subject
            .display_job_applications('job-company-person',
                                      job.id))
            .to eq([@job_application])
        end
      end

      context 'When 2 Job Seekers applied' do
        before(:each) do
          @job_application = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker1,
            job: job
          )
          @job_application1 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker2,
            job: job
          )
          @job_application2 = FactoryBot.create(
            :job_application,
            job_seeker: job_seeker3,
            job: job1
          )
        end

        context 'When no Application per page restriction is set' do
          it 'return 2 job applications' do
            expect(subject
              .display_job_applications('job-company-person',
                                        job.id))
              .to include(@job_application,
                          @job_application1)
          end
        end

        context 'When restricting 1 applications per page' do
          let(:result) do
            subject.display_job_applications('job-company-person',
                                             job.id,
                                             1)
          end
          it 'return 1 job application' do
            expect(result.size).to be(1)
          end

          it 'found 2 job applications' do
            expect(result.count).to be(2)
          end

          it 'return first job application' do
            expect(result).to include(@job_application1)
          end
        end
      end
    end
  end
end
