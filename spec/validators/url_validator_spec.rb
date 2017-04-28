require 'rails_helper'
require 'support/validator_helper'
include ValidatorHelper

RSpec.describe UrlValidator do
  let(:model) { ValidatorHelper::test_model_class } 
  let(:record) { model.new }

  before(:each) do
    record.class_eval do
      validates :test_attr, url: true
    end
  end

  it 'adds an error when the Url is invalid' do
    record.test_attr = 'htps://ide.c9.io/pcaston/metsplus'
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_attr: ['is not an url']
    )
  end

  it 'does not add an error when the Url is valid' do
    record.test_attr = 'https://ide.c9.io/pcaston/metsplus'
    expect do
      record.valid?
    end.not_to change(record.errors.messages, :count).from(0)
  end
end
