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
 end
