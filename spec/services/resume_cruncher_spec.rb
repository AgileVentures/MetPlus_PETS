require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe ResumeCruncher, type: :model do

  before(:each) do
    stub_request(:post, CruncherService.service_url + '/authenticate').
        to_return(body: "{\"token\": \"12345\"}", status: 200,
        :headers => {'Content-Type'=> 'application/json'})
  end

  describe 'File upload' do
    it 'returns success (true) for valid file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      expect(ResumeCruncher.upload_resume(file,
                                  'Admin-Assistant-Resume.pdf',
                                  'test_id')).to be true
    end

    it 'returns fail (false) for invalid file type' do

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_raise(RuntimeError)
          
      file = fixture_file_upload('files/Test File.zzz')
      expect{ ResumeCruncher.upload_resume(file,
                                  'Test File.zzz',
                                  'test_id') }.
                    to raise_error(RuntimeError)
    end
  end

end
