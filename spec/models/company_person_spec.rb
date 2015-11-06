require 'rails_helper'

describe CompanyPerson, type: :model do

  it 'should have a valid factory' do
    expect(FactoryGirl.build(:company_person)).to be_valid
  end

  it{ is_expected.to have_and_belong_to_many :company_roles }

  describe 'Database schema' do
    it { is_expected.to have_db_column :company_id}
    it { is_expected.to have_db_column :address_id}
  end
  
  describe 'Associations' do
    it { is_expected.to belong_to :address }
    it { is_expected.to belong_to :company }
    it { is_expected.to have_and_belong_to_many(:company_roles).
             join_table('company_people_roles')}
  end

  describe 'check model restrictions' do 

  describe 'Email check' do
    it { should validate_presence_of(:email)}
    it { should_not allow_value('abc', 'abc@abc', 'abcdefghjjkll').for(:email)}
  end

  describe 'FirstName check' do
    it { is_expected.to validate_presence_of :first_name }
  end

  describe 'LastName check' do
    it { is_expected.to validate_presence_of :last_name }
  end

  describe 'Phone check' do
    it { should_not allow_value('asd', '123456', '123 123 12345', 
      '123 1231 1234', '1123 123 1234', ' 123 123 1234').for(:phone)}

    it { should allow_value('+1 123 123 1234', '123 123 1234', 
      '(123) 123 1234', '1231231234', '+1 (123) 1231234').for(:phone)}
  end
end

  context "#acting_as?" do
    it "returns true for supermodel class and name" do
      expect(CompanyPerson.acting_as? :user).to be true
      expect(CompanyPerson.acting_as? User).to  be true
    end

    it "returns false for anything other than supermodel" do
      expect(CompanyPerson.acting_as? :model).to be false
      expect(CompanyPerson.acting_as? String).to be false
    end
  end

end
