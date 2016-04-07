require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe ResumeCruncher, type: :model do

  describe 'File upload' do
    it 'returns success (true) for valid file type' do
      file = fixture_file_upload('files/Admin-Assistant-Resume.pdf')
      expect(ResumeCruncher.upload_resume(file,
                                  'Admin-Assistant-Resume.pdf',
                                  'test_user')).to be true
    end
  end

end
