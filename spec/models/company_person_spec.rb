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
    it { is_expected.to have_db_column :title }
  end

  describe 'Validations' do
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
    it { should_not allow_value('+1 123 123 1234', 'asd', '123456', '123 123 12345',
               '123 1231  1234', '1123 123 1234', ' 123 123 1234', 
               '(234 1234 1234', '786) 1243 3578').for(:phone)}
    it { should allow_value('123 123 1234', '(123) 123 1234', '1231231234',
               '1-910-123-9158 x2851', '1-872-928-5886', '833-638-6551 x16825').for(:phone)}
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

  describe '#is_company_contact?' do
    let(:company) {FactoryGirl.create(:company)}
    let(:company1) {FactoryGirl.create(:company)}
    let(:person) {FactoryGirl.create(:company_contact, :company => company)}
    let(:person_other_company) {FactoryGirl.create(:company_contact, :company => company1)}
    it 'correct' do
      expect(person.is_company_contact?(company)).to be true
    end
    it 'incorrect' do
      expect(person_other_company.is_company_contact?(company)).to be false
    end
  end

  describe '#is_company_admin?' do
    let(:company) {FactoryGirl.create(:company)}
    let(:company1) {FactoryGirl.create(:company)}
    let(:person) {FactoryGirl.create(:company_admin, :company => company)}
    let(:person_other_company) {FactoryGirl.create(:company_admin, :company => company1)}
    it 'correct' do
      expect(person.is_company_admin?(company)).to be true
    end
    it 'incorrect' do
      expect(person_other_company.is_company_admin?(company)).to be false
    end
  end

  describe 'scope all_company_people' do
    let(:company) { FactoryGirl.create(:company) }

    let!(:cp1) { FactoryGirl.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp3) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp4) { FactoryGirl.create(:company_contact, company: company) }

    it 'returns all company people' do
      expect(CompanyPerson.all_company_people(company)).
                    to include cp1, cp2, cp3, cp4
    end
  end
end
