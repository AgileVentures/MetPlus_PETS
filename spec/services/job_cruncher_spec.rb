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
    it 'returns the matching jobs for a valid request' do
      stub_cruncher_match_jobs
      expect { JobCruncher.match_jobs(1).not_to be nil }
    end

    it 'returns nil in case of a wrong resume id' do
      stub_cruncher_match_jobs_fail('RESUME_NOT_FOUND')

      expect { JobCruncher.match_jobs(1).to be nil }
    end

  end
 end
