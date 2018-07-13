require 'rails_helper'

RSpec.describe Jobs::SynchronizeCruncher do
  describe '#call' do
    let(:job_query_double) { instance_double(Jobs::Query) }
    let(:job_cruncher_service_double) { class_double(JobCruncher) }
    let(:subject) { Jobs::SynchronizeCruncher.new }
    before(:each) do
      subject.job_query = job_query_double
      subject.job_cruncher = job_cruncher_service_double
    end

    context 'When no jobs exist in the database' do
      before(:each) do
        allow(job_query_double).to receive(:all).and_return([])
      end

      it 'never try to save' do
        expect(job_cruncher_service_double).not_to receive(:create_job)
        expect(job_cruncher_service_double).not_to receive(:update_job)
        subject.call
      end
    end

    context 'When Jobs exist on the database' do
      context 'When all jobs exist in the cruncher' do
        before(:each) do
          expect(job_query_double).to receive(:all).and_return(
            [
              Job.new(id: 1, title: 'some title', description: 'some description'),
              Job.new(id: 2, title: 'some other title',
                      description: 'some other description')
            ]
          )
        end

        it 'should be called twice' do
          expect(job_cruncher_service_double).to receive(:update_job)
            .twice.and_return(true, true)
          expect(job_cruncher_service_double).not_to receive(:create_job)
          subject.call
        end
      end

      context 'When a job does not exist in the cruncher' do
        before(:each) do
          expect(job_query_double).to receive(:all).and_return(
            [
              Job.new(id: 1, title: 'some title', description: 'some description'),
              Job.new(id: 2, title: 'some other title',
                      description: 'some other description')
            ]
          )
        end

        it 'should be called twice' do
          expect(job_cruncher_service_double).to receive(:update_job)
            .twice.and_return(true, false)
          expect(job_cruncher_service_double).to receive(:create_job)
            .once.with(2, 'some other title', 'some other description')

          subject.call
        end
      end
    end
  end
end
