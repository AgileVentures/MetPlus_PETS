require 'rails_helper'

RSpec.describe Resume, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:resume)).to be_valid
    end
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :file_name }
    it { is_expected.to have_db_column :job_seeker_id }
  end

  describe 'Resume' do
    it 'is valid with all required fields' do
      file = fixture_file_upload('files/Janitor-Resume.doc')
      resume = Resume.new(file_name: 'testfile.doc',
              job_seeker_id: FactoryGirl.create(:job_seeker).id,
              file: file)

      expect(resume).to be_valid
    end
  end
end
