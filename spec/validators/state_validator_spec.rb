require 'rails_helper'
require 'support/validator_helper'
include ValidatorHelper

RSpec.describe StateValidator do
  let(:model) { ValidatorHelper.test_model_class }
  let(:record) { model.new }

  before(:each) do
    record.class_eval do
      validates :test_attr, State: true
    end
  end

  it 'adds an error when the State is invalid' do
    record.test_attr = 'MX'
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_attr: ['not present in the list of states']
    )
  end

  it 'does not add an error when the State is valid' do
    record.test_attr = 'MA'
    expect do
      record.valid?
    end.not_to change(record.errors.messages, :count).from(0)
  end
end
