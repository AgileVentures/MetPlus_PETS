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
      it { validate_presence_of :ein}
    end
    describe 'Email' do
      it { should_not allow_value('asd', 'john@company')
                          .for(:email)}
      it { should allow_value('johndoe@company.com')
                      .for(:email)}
    end
    describe 'Website' do
      it { should_not allow_value('asd', 'ftp://company.com', 'http:', 'http://', 'https', 'https:', 'https://',
                                  'http://place.com###Bammm')
                          .for(:website)}
      it { should allow_value('http://company.com', 'https://company.com', 'http://w.company.com/info',
                              'https://comp.com:10/test/1/wasd', 'http://company.com/')
                      .for(:website)}
    end
  end

  describe 'Address' do
    subject { FactoryGirl.build(:company) }
    describe 'creation' do
      it {
        addr = FactoryGirl.build :address
        subject.addresses << addr
        subject.save!
        expect(Company.find_by_name('My company').addresses.length).to be 1
      }
    end
  end
end
