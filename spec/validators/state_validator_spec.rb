require 'rails_helper'

RSpec.describe StateValidator do
  let(:model) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :test_State

      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestModel')
      end
    end
  end

  let(:record) { model.new }

  before(:each) do
    record.class_eval do
      validates :test_State, State: true
    end
  end

  it 'adds an error when the State is invalid' do
    record.test_State = 'MX'
    expect do
      record.valid?
    end.to change(record.errors, :messages).from({}).to a_hash_including(
      test_State: ['not present in the list of states']
    )
  end

  it 'does not add an error when the State is valid' do
    record.test_State = 'MA'
    expect do
      record.valid?
    end.not_to change(record.errors.messages, :count).from(0)
  end
end
