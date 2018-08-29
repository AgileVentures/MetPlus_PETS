require 'rails_helper'
require 'support/validator_helper'

RSpec.describe YearOfBirthValidator, :include_validator_helpers do
  let(:model) { test_model_class }
  let(:record) { model.new }

  before(:each) do
    record.class_eval do
      validates :test_attr, year_of_birth: true
    end
  end

  it 'adds an error when the age is more than 100 years' do
    record.test_attr = 100.years.ago.year - 1.day
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_attr: ['age need to be between 16 and 100']
    )
  end

  it 'adds an error when the age is less than 16 years' do
    record.test_attr = 15.years.ago.year
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_attr: ['age need to be between 16 and 100']
    )
  end

  it 'adds an error when the age is in the future' do
    record.test_attr = Date.today.year + 1.day
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_attr: ['age need to be between 16 and 100']
    )
  end

  it 'does not add an error when is exactly 100 years' do
    record.test_attr = 100.years.ago.year
    expect do
      record.valid?
    end.not_to change(record.errors.messages, :count).from(0)
  end
end
