require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe CruncherService, type: :model do

  describe 'Initialization' do
    it 'Establishes service URL' do
      expect(CruncherService.service_url).to eq ENV['CRUNCHER_SERVICE_URL']
    end
  end

  describe 'File upload' do
    it 'returns success (true) for valid file type' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      expect(CruncherService.upload_file(file,
                                  'Admin-Assistant-Resume.pdf',
                                  'test_user')).to be true
    end

    it 'raises error for invalid file type' do
      file = fixture_file_upload('files/Example Excel File.xls')
      expect{ CruncherService.upload_file(file,
                                  'Example Excel File.xls',
                                  'test_user') }.
                    to raise_error(RuntimeError)
    end

    it 'raises error for unknown MIME type' do
      file = fixture_file_upload('files/Test File.zzz')
      expect{ CruncherService.upload_file(file,
                                  'Test File.zzz',
                                  'test_user') }.
                    to raise_error(RuntimeError)
    end
  end

end
