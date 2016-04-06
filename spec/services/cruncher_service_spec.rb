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

    it 'returns failure (false) for invalid file type' do
      file = fixture_file_upload('files/Controls-Matrix-with-Key-Controls.xls')
      expect(CruncherService.upload_file(file,
                                  'Controls-Matrix-with-Key-Controls.xls',
                                  'test_user')).to be false
    end
  end

  class ResumeCruncher
    def self.post_resume(resume_file, file_name, user_id)
      CruncherService.upload_file(resume_file, file_name, user_id)
    end
  end

end
