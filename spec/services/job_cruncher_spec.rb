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

  describe 'update job' do
    it 'returns success (true) for update to existing job' do
      stub_cruncher_job_update

      expect(JobCruncher.update_job(10,'Software Engineer',
              'description of the job')).to be true
    end

    it 'returns failure (false) for job not found' do
      stub_cruncher_job_update_fail('JOB_NOT_FOUND')

      expect(JobCruncher.update_job(10,'Software Engineer',
              'description of the job')).to be false
    end
  end

  describe 'match jobs' do
    it 'returns array of job matches for a valid request' do
      stub_cruncher_match_jobs
      results = JobCruncher.match_jobs(1)
      expect(results).not_to be nil
      expect(results.class).to be Array
      expect(results[0][0]).to be 3
      expect(results[0][1]).to be 4.7
      expect(results[2][0]).to be 6
      expect(results[2][1]).to be 3.4
    end

    it 'returns nil in case of a wrong resume id' do
      stub_cruncher_match_jobs_fail('RESUME_NOT_FOUND')

      expect { JobCruncher.match_jobs(1).to be nil }
    end

  end
 end
