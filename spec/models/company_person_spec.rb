require 'rails_helper'

describe CompanyPerson, type: :model do
  it 'should have a valid factory' do
    expect(FactoryBot.build(:company_person)).to be_valid
  end

  it { is_expected.to have_and_belong_to_many :company_roles }

  describe 'Database schema' do
    it { is_expected.to have_db_column :company_id }
    it { is_expected.to have_db_column :address_id }
    it { is_expected.to have_db_column :status }
    it { is_expected.to have_db_column :title }
    it { is_expected.to have_db_column :status }
  end

  describe 'Validations' do
    describe 'status' do
      it 'Status -1 should generate exception' do
        expect { subject.status = -1 }
          .to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
      end
      it 'Status 0 should be company_pending' do
        subject.status = 0
        expect(subject.status).to eq 'company_pending'
      end
      it 'Status 1 should be invited' do
        subject.status = 1
        expect(subject.status).to eq 'invited'
      end
      it 'Status 2 should be active' do
        subject.status = 2
        expect(subject.status).to eq 'active'
      end
      it 'Status 3 should be inactive' do
        subject.status = 3
        expect(subject.status).to eq 'inactive'
      end
      it 'Status 4 should be company_denied' do
        subject.status = 4
        expect(subject.status).to eq 'company_denied'
      end
      it 'Status 5 should generate error' do
        expect { subject.status = 5 }
          .to raise_error(ArgumentError).with_message('\'5\' is not a valid status')
      end
    end

    describe 'not_removing_sole_company_admin' do
      let(:ca) { FactoryBot.create(:company_admin) }

      it 'invalidates attempted removal' do
        ca_role = ca.company_roles[0]
        ca.company_roles.delete(ca_role)
        ca.valid?
        expect(ca).to_not be_valid
        expect(ca.errors.full_messages)
          .to include 'Company admin cannot be unset for sole company admin.'
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to :address }
    it { is_expected.to belong_to :company }
    it {
      is_expected.to have_and_belong_to_many(:company_roles)
        .join_table('company_people_roles')
    }
  end

  describe 'check model restrictions' do
    it { should validate_presence_of(:email) }
    it { should_not allow_value('abc', 'abc@abc', 'abcdefghjjkll').for(:email) }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it {
      should_not allow_value('asd', '123456', '123 1231  1234', '1    123 123 1234',
                             ' 123 123 1234', '(234 1234 1234',
                             '786) 1243 3578').for(:phone)
    }
    it {
      should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
                         '1 231 231 2345', '12312312345', '1231231234',
                         '1-910-123-9158 x2851', '1-872-928-5886',
                         '833-638-6551 x16825').for(:phone)
    }
  end

  context '#acting_as?' do
    it 'returns true for supermodel class and name' do
      expect(CompanyPerson.acting_as?(:user)).to be true
      expect(CompanyPerson.acting_as?(User)).to  be true
    end

    it 'returns false for anything other than supermodel' do
      expect(CompanyPerson.acting_as?(:model)).to be false
      expect(CompanyPerson.acting_as?(String)).to be false
    end
  end

  describe '#is_company_contact?' do
    let(:company) { FactoryBot.create(:company) }
    let(:company1) { FactoryBot.create(:company) }
    let(:person) { FactoryBot.create(:company_contact, company: company) }
    let(:person_other_company) { FactoryBot.create(:company_contact, company: company1) }
    it 'correct' do
      expect(person.is_company_contact?(company)).to be true
    end
    it 'incorrect' do
      expect(person_other_company.is_company_contact?(company)).to be false
    end
  end

  describe '#is_company_admin?' do
    let(:company) { FactoryBot.create(:company) }
    let(:company1) { FactoryBot.create(:company) }
    let(:person) { FactoryBot.create(:company_admin, company: company) }
    let(:person_other_company) { FactoryBot.create(:company_admin, company: company1) }
    it 'correct' do
      expect(person.is_company_admin?(company)).to be true
    end
    it 'incorrect' do
      expect(person_other_company.is_company_admin?(company)).to be false
    end
  end

  describe 'scope all_company_people' do
    let(:company) { FactoryBot.create(:company) }

    let!(:cp1) { FactoryBot.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryBot.create(:company_contact, company: company) }
    let!(:cp3) { FactoryBot.create(:company_contact, company: company) }
    let!(:cp4) { FactoryBot.create(:company_contact, company: company) }

    it 'returns all company people' do
      expect(CompanyPerson.all_company_people(company))
        .to include cp1, cp2, cp3, cp4
    end
  end
end
