require 'rails_helper'
include ActionDispatch::TestProcess
include ServiceStubHelpers::Cruncher

RSpec.describe JobCruncher, type: :model do

  before(:each) do
    stub_cruncher_authenticate
  end

  describe 'create job' do
    it 'returns success (true) for create a new job' do
      stub_cruncher_job_create

      expect(JobCruncher.create_job(10,'Software Engineer',
              'description of the job')).to be true
    end

    it 'returns failure (false) for job already exists' do
      stub_cruncher_job_create_fail('JOB_ID_EXISTS')

      expect(JobCruncher.create_job(10,'Software Engineer',
              'description of the job')).to be false
    end
  end

  describe 'match jobs' do
    it 'returns hash of matching jobs for a valid request' do
      stub_cruncher_match_jobs
      results = JobCruncher.match_jobs(1)
      expect(results).not_to be nil
      expect(results.class).to be Hash
      expect(results[3]).to be 4.7
    end

    it 'returns nil in case of a wrong resume id' do
      stub_cruncher_match_jobs_fail('RESUME_NOT_FOUND')

      expect { JobCruncher.match_jobs(1).to be nil }
    end

  end
 end
