require 'rails_helper'

RSpec.describe Companies::DestroyCompany do
  describe '#call' do
    let(:company) { double }
    let(:company_query_stub) { double }
    let(:subject) { Companies::DestroyCompany.new(double, company_query_stub) }
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
        expect(subject).to receive(:authorized!)
          .with(company_with_jobs, 'destroy')
        company_with_jobs.id = 1
        allow(subject.query).to receive(:find_by_id).and_return(company_with_jobs)
      end

      it 'does update the company status to inactive' do
        expect(company_with_jobs).to receive(:inactive)
        result = subject.call(1)
        expect(result).to eq(company_with_jobs)
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
      end

      it 'does udpdate the company status to inactive' do
        expect(company).to receive(:inactive)
        result = subject.call(1)
        expect(result).to eq(company)
      end
    end
  end
end
