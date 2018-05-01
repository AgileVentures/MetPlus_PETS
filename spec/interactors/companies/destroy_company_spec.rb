require 'rails_helper'

include ServiceStubHelpers::Cruncher

RSpec.describe Companies::DestroyCompany do
  describe '#call' do
    let(:company) { double }
    let(:company_query_stub) { double }
    let(:job_application_query) { double }
    let(:reject_iterator) { double(JobApplications::Reject) }
    let(:subject) do
      Companies::DestroyCompany.new(
        double, company_query_stub, job_application_query, reject_iterator)
    end
    context 'cannot find company' do
      before(:each) do
        allow(subject.query).to receive(:find_by_id)
          .and_raise(ActiveRecord::RecordNotFound)
      end

      it 'raises ActiveRecord Exception' do
        expect(subject.query).not_to receive(:destroy)
        expect { subject.call(1) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'user not authorized to delete a company' do
      let(:agency) { FactoryBot.build(:agency) }
      let(:company_with_jobs) do
        job = FactoryBot.build(:job)
        job.id = 1
        company = FactoryBot.build(:company, agencies: [agency], jobs: [job])
        allow(company.jobs).to receive(:exists?).and_return true
        company
      end

      before(:each) do
        expect(subject).to receive(:authorized!)
          .with(company_with_jobs, 'destroy')
          .and_raise(Authorization::NotAuthorizedError)
        company_with_jobs.id = 1
        allow(subject.query).to receive(:find_by_id).and_return(company_with_jobs)
      end

      it 'does not delete the company' do
        expect(subject.query).not_to receive(:destroy)
        expect { subject.call(1) }.to raise_error(Authorization::NotAuthorizedError)
      end
    end

    context 'company with jobs' do
      let(:agency) { FactoryBot.build(:agency) }
      let(:company_with_jobs) do
        job = FactoryBot.build(:job)
        job.id = 1
        company = FactoryBot.build(:company, agencies: [agency], jobs: [job])
        allow(company.jobs).to receive(:exists?).and_return true
        company
      end

      before(:each) do
        stub_cruncher_authenticate
        stub_cruncher_job_create
      end

      context 'no job applications' do
        before(:each) do
          expect(subject).to receive(:authorized!)
            .with(company_with_jobs, 'destroy')
          expect(job_application_query).to receive(:find_by_company)
            .and_return([])
          company_with_jobs.id = 1
          allow(subject.query).to receive(:find_by_id).and_return(company_with_jobs)
          expect(reject_iterator).not_to receive(:call)
        end

        it 'does update the company status to inactive' do
          expect(company_with_jobs).to receive(:inactive)
          result = subject.call(1)
          expect(result).to eq(company_with_jobs)
        end
      end

      context 'a job as application' do
        let(:job_application) do
          FactoryBot.build(:job_application)
        end

        before(:each) do
          expect(subject).to receive(:authorized!)
            .with(company_with_jobs, 'destroy')
          expect(job_application_query).to receive(:find_by_company)
            .and_return([job_application])

          company_with_jobs.id = 1
          allow(subject.query).to receive(:find_by_id).and_return(company_with_jobs)
          expect(reject_iterator).to receive(:call)
            .with(job_application, 'Company removed from the system')
        end

        it 'does update the company status to inactive' do
          expect(company_with_jobs).to receive(:inactive)
          result = subject.call(1)
          expect(result).to eq(company_with_jobs)
        end

        it 'calls the job application rejection iterator' do
          expect(company_with_jobs).to receive(:inactive)
          result = subject.call(10)
          expect(result).to eq(company_with_jobs)
        end
      end
    end

    context 'company without jobs' do
      let(:agency) { FactoryBot.build(:agency) }
      let(:company) do
        FactoryBot.build(:company, agencies: [agency])
      end

      before(:each) do
        expect(subject).to receive(:authorized!)
          .with(company, 'destroy')
        allow(subject.query).to receive(:find_by_id).and_return(company)
        allow(job_application_query).to receive(:find_by_company)
          .and_return([])
      end

      it 'does udpdate the company status to inactive' do
        expect(company).to receive(:inactive)
        result = subject.call(1)
        expect(result).to eq(company)
      end
    end
  end
end
