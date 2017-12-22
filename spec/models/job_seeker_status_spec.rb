require 'rails_helper'

describe JobSeekerStatus, type: :model do
  describe 'database fields' do
    it { is_expected.to have_db_column :description }
    it { is_expected.to have_db_column :short_description }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :short_description }

    it { is_expected.to validate_length_of(:description).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_least(10) }

    it { is_expected.to validate_length_of(:short_description).is_at_most(25) }
    it { is_expected.to validate_length_of(:short_description).is_at_least(5) }
  end
end
