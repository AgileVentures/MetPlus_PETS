require 'rails_helper'
include ActionDispatch::TestProcess
include ServiceStubHelpers::Cruncher

RSpec.describe ResumeCruncher, type: :model do

  before(:each) do
    stub_cruncher_authenticate
  end

  describe 'File upload' do
    it 'returns success (true) for valid file type' do

      stub_cruncher_file_upload

      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      expect(ResumeCruncher.upload_resume(file,
                                  'Admin-Assistant-Resume.pdf',
                                  'test_id')).to be true
    end

    it 'returns fail (false) for invalid file type' do

      stub_cruncher_file_upload_error

      file = fixture_file_upload('files/Test File.zzz')
      expect{ ResumeCruncher.upload_resume(file,
                                  'Test File.zzz',
                                  'test_id') }.
                    to raise_error(RuntimeError)
    end
  end

end
