require 'rails_helper'
include ServiceStubHelpers::Cruncher

class TestConcernJobsViewerClass < ApplicationController
  include JobsViewer
end

RSpec.describe TestConcernJobsViewerClass do
  let(:company) { FactoryBot.create(:company) }
  let(:cmpy_person1) { FactoryBot.create(:company_contact, company: company) }
  let(:job1) { FactoryBot.create(:job, title: 'Software Developer', company: company) }
  let(:job2) { FactoryBot.create(:job, title: 'Software Tester', company: company) }
  let(:job3) do
    FactoryBot.create(:job, title: 'Business Analyst',
                            company: company,
                            created_at: Date.new(2010, 1, 1))
  end
  let(:job_fields) { TestConcernJobsViewerClass::FIELDS_IN_JOB_TYPE }

  describe '#display_jobs' do
    before(:each) do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      warden.set_user cmpy_person1
    end

    it 'returns all jobs for a specified company' do
      expect(subject.display_jobs('my-company-all'))
        .to match_array [job1, job2, job3]
    end

    it 'returns all fields for jobs for a specified company' do
      expect(subject.job_fields('my-company-all'))
        .to match_array job_fields['my-company-all']
    end

    it 'returns all recent jobs' do
      expect(subject.display_jobs('recent-jobs'))
        .to match_array [job1, job2]
    end

    it 'returns all fields for recent jobs' do
      expect(subject.job_fields('recent-jobs'))
        .to match_array job_fields['recent-jobs']
    end
  end
end
