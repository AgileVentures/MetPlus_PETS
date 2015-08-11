require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'Check model restrictions' do
    subject { FactoryGirl.build(:skill) }
    describe 'Name' do
      it {should validate_presence_of(:name) }
      it {should validate_length_of(:name)}
    end
    describe 'Description' do
      it {should validate_presence_of(:description) }
      it {should validate_length_of(:description)}
    end
  end
end
