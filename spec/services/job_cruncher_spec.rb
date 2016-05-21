require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe JobCruncher, type: :model do

  before(:each) do
   stub_request(:post,CruncherService.service_url + '/authenticate').
       to_return(body: "{\"token\": \"12345\"}", status: 200,
        :headers => {'Content-Type' => 'application/json'})
  end

  describe 'create job' do
    it 'returns success (true) for create a new job' do

       stub_request(:post, CruncherService.service_url + '/job/create').
           to_return(body: "{\"resultCode\":\"SUCCESS\"}" , status: 200,
           :headers => {'Content-Type' => 'application/json'})
       expect(JobCruncher.create_job(10,'Software Engineer',
              'description of the job')).to be true
    end

    it 'returns fail(false) if cruncher create fails' do

       stub_request(:post, CruncherService.service_url + '/job/create').
           to_return(body: "{\"resultCode\":\"FAILURE\"}" ,
           :headers => {'Content-Type' => 'application/json'})
       expect(JobCruncher.create_job(11,'Software Engineer2',
              'description of the job2')).to be false
    end

    it 'returns failure (false) for job already exists' do

       stub_request(:post, CruncherService.service_url + '/job/create').
           to_return(body: "{\"resultCode\":\"JOB_ID_EXISTS\"}" , status: 200,
           :headers => {'Content-Type' => 'application/json'})
       expect(JobCruncher.create_job(10,'Software Engineer',
              'description of the job')).to be false
    end
  end
 end
   
