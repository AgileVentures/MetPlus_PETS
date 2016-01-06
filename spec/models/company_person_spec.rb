require 'rails_helper'

describe CompanyPerson, type: :model do

  it 'should have a valid factory' do
    expect(FactoryGirl.build(:company_person)).to be_valid
  end

  it{ is_expected.to have_and_belong_to_many :company_roles }

  describe 'Database schema' do
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :address_id }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :company_id }
    it { is_expected.to validate_inclusion_of(:status).
            in_array(CompanyPerson::STATUS.values)}
  end

  describe 'Associations' do
    it { is_expected.to belong_to :address }
    it { is_expected.to belong_to :company }
    it { is_expected.to have_and_belong_to_many(:company_roles).
             join_table('company_people_roles')}
  end

  describe 'check model restrictions' do
    it { should validate_presence_of(:email)}
    it { should_not allow_value('abc', 'abc@abc', 'abcdefghjjkll').for(:email)}
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { should_not allow_value('asd', '123456', '123 123 12345',
        '123 1231 1234', '1123 123 1234', ' 123 123 1234').for(:phone)}
    it { should allow_value('+1 123 123 1234', '123 123 1234',
        '(123) 123 1234', '1231231234', '+1 (123) 1231234').for(:phone)}
    it 'is invalid without an agency association' do
      person = CompanyPerson.new()
      person.valid?
      expect(person.errors[:company_id]).to include("can't be blank")
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
