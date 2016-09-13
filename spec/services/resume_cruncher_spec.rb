require 'rails_helper'
include ActionDispatch::TestProcess
include ServiceStubHelpers::Cruncher

RSpec.describe ResumeCruncher, type: :model do

  let(:testfile)     {'files/Admin-Assistant-Resume.pdf'}

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

      file = fixture_file_upload('files/Test File.zzz')
      expect{ ResumeCruncher.upload_resume(file,
                                  'Test File.zzz',
                                  'test_id') }.
                    to raise_error(RuntimeError)
    end
  end

  describe 'File download' do
    it 'returns Tempfile if résumé is found' do

      stub_cruncher_file_download(testfile)
      expect(ResumeCruncher.download_resume(1).class).to be Tempfile
    end

    it 'returns nil if résumé is not found' do

      stub_cruncher_file_download_notfound
      expect(ResumeCruncher.download_resume(2)).to be_nil
    end
  end


  describe 'match resumes' do

    it 'returns array of résumé matches for a valid request' do
      stub_cruncher_match_resumes
      results = ResumeCruncher.match_resumes(1)
      expect(results).not_to be nil
      expect(results.class).to be Array
      expect(results[0][0]).to be 7
      expect(results[0][1]).to be 4.9
      expect(results[1][0]).to be 5
      expect(results[1][1]).to be 3.8
      expect(results[2][0]).to be 2
      expect(results[2][1]).to be 2.0
    end

  end

end
