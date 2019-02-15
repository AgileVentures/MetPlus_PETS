require 'rails_helper'

class TestEntity < ApplicationRecord
  # This class allows for testing of StatusChange.  It is piggy-backing
  # on the job_applications table since the tests require the instantiation
  # of the enum :status field in the DB
  self.table_name = 'job_applications'

  enum status: %i[hello goodbye still_here]

  has_many :status_changes, as: :entity, dependent: :destroy
end

RSpec.describe StatusChange, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryBot.build(:status_change)).to be_valid
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
    it {
      is_expected.to validate_numericality_of(:status_change_to)
        .only_integer.is_greater_than_or_equal_to(0)
    }

    it {
      is_expected.to validate_numericality_of(:status_change_from)
        .only_integer.is_greater_than_or_equal_to(0).allow_nil
    }
  end

  describe 'Class methods' do
    let(:entity1) { TestEntity.create }
    let(:entity2) { TestEntity.create }

    it 'adds a status change record for an entity' do
      expect { StatusChange.update_status_history(entity1, :hello) }
        .to change(StatusChange, :count).by 1
      expect(entity1.status_changes.count).to eq 1
    end

    it 'returns status change time for an entity' do
      StatusChange.update_status_history(entity1, :hello)
      sleep(1)
      StatusChange.update_status_history(entity2, :hello)

      StatusChange.update_status_history(entity1, :goodbye)
      sleep(1)
      StatusChange.update_status_history(entity2, :still_here)

      expect(StatusChange.status_change_time(entity1, :hello))
        .to eq StatusChange.first.created_at

      expect(StatusChange.status_change_time(entity1, :goodbye))
        .to eq StatusChange.third.created_at

      expect(StatusChange.status_change_time(entity2, :hello))
        .to eq StatusChange.second.created_at
      expect(StatusChange.status_change_time(entity2, :still_here))
        .to eq StatusChange.last.created_at
    end

    it 'returns an array of times for multiple occurences of status' do
      t1 = StatusChange.update_status_history(entity1, :hello)
                       .last.created_at
      StatusChange.update_status_history(entity1, :goodbye)
                  .last.created_at
      t3 = StatusChange.update_status_history(entity1, :hello)
                       .last.created_at

      change_times = StatusChange.status_change_time(entity1, :hello, :all)

      expect(change_times).to eq [t1, t3]
    end

    it 'raises exception with invalid time(s) selector' do
      StatusChange.update_status_history(entity1, :hello)
      StatusChange.update_status_history(entity1, :good_bye)

      expect { StatusChange.status_change_time(entity1, :hello, :unknown) }
        .to raise_error(ArgumentError, "Invalid 'which' argument")
    end
  end
end
