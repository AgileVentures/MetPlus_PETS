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
    let(:ja1) { FactoryGirl.create(:job_application) }
    let(:ja2) { FactoryGirl.create(:job_application) }

    it 'adds a status change record for an entity' do
      expect{ StatusChange.update_status_history(ja1, nil, :active) }.
            to change(StatusChange, :count).by 1
      expect(ja1.status_changes.count).to eq 1
    end

    it 'returns status change time for an entity' do
      StatusChange.update_status_history(ja1, nil, :active)
      sleep(1)
      StatusChange.update_status_history(ja2, nil, :active)
      StatusChange.update_status_history(ja1, :active, :accepted)
      sleep(1)
      StatusChange.update_status_history(ja2, :active, :accepted)

      expect(StatusChange.status_change_time(ja1, :active)).
          to eq StatusChange.first.created_at

      expect(StatusChange.status_change_time(ja1, :accepted)).
          to eq StatusChange.third.created_at

      expect(StatusChange.status_change_time(ja2, :active)).
          to eq StatusChange.second.created_at
      expect(StatusChange.status_change_time(ja2, :accepted)).
          to eq StatusChange.last.created_at
    end

    it 'returns an array of times for multiple occurences of status' do
      t1 = StatusChange.update_status_history(ja1, nil, :active).
                      last.created_at
      t2 = StatusChange.update_status_history(ja1, :active, :accepted).
                      last.created_at
      t3 = StatusChange.update_status_history(ja1, :accepted, :active).
                      last.created_at

      change_times = StatusChange.status_change_time(ja1, :active, :all)

      expect(change_times).to eq [t1, t3]
    end

    it 'raises exception with invalid time(s) selector' do
      StatusChange.update_status_history(ja1, nil, :active)
      StatusChange.update_status_history(ja1, :active, :accepted)

      expect {StatusChange.status_change_time(ja1, :active, :unknown)}.
                  to raise_error(ArgumentError, "Invalid 'which' argument")
    end
  end

end
