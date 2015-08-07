require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { FactoryGirl.build(:company) }
  describe 'Validation' do
    describe 'phone' do
      it { should_not allow_value('asd', '123456', '123 123 12345', '123 1231 1234', '1123 123 1234', ' 123 123 1234')
                          .for(:phone)}
      it { should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234', '1231231234', '+1 (123) 1231234')
                          .for(:phone)}
    end
    describe 'EIN' do
      it { should_not allow_value('asd', '123456', '123-456789', '12-34567891', '00-0000000', '000000000')
                          .for(:ein)}
      it { should allow_value('12-3456789', '123456789')
                      .for(:ein)}
    end
  end
end
