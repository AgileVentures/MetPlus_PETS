require 'rails_helper'

RSpec.describe StatusChange, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:status_change)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :entity }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :status_change_from }
    it { is_expected.to have_db_column :status_change_to }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:status_change_to) }
    it { is_expected.to validate_numericality_of(:status_change_to).
                  only_integer.is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_numericality_of(:status_change_from).
                  only_integer.is_greater_than_or_equal_to(0).allow_nil }
  end

  describe 'Class methods' do
    let(:ja) { FactoryGirl.create(:job_application) }

    it 'adds a status change record for an entity' do
      expect{ StatusChange.update_status_history(ja, nil, :active) }.
            to change(StatusChange, :count).by 1
      expect(ja.status_changes.count).to eq 1
    end

    it 'returns status change time for an entity' do
      StatusChange.update_status_history(ja, nil, :active)
      expect(StatusChange.status_change_time(ja, :active)).
          to eq StatusChange.first.created_at
    end
  end

end
