require 'rails_helper'

RSpec.describe UrlValidator do
  let(:model) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :test_url

      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestModel')
      end
    end
  end

  let(:record) { model.new }

  before(:each) do
    record.class_eval do
      validates :test_url, :url => true
    end
  end

  it 'adds an error when the Url is invalid' do
    record.test_url = 'htps://ide.c9.io/pcaston/metsplus'
    expect {
    record.valid?
    }.to change(record.errors, :messages).from({}).to a_hash_including(
    test_url: ['is not an url']
    )
  end

  it 'does not add an error when the Url is valid' do
    record.test_url = 'https://ide.c9.io/pcaston/metsplus'
    expect {
    record.valid?
    }.not_to change(record.errors.messages, :count).from(0)
  end
end
