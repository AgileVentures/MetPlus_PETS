require 'rails_helper'

RSpec.describe CruncherService, type: :model do

  describe 'Initialization' do
    it 'Establishes service URL' do
      expect(CruncherService.service_url).to eq ENV['CRUNCHER_SERVICE_URL']
    end
  end

  class ResumeCruncher
    def self.post_resume(resume_file, file_name, user_id)
      CruncherService.upload_file(resume_file, file_name, user_id)
    end
  end
  
end
