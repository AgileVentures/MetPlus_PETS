require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :agency_id }
    it { is_expected.to have_db_column :code }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :agency }
    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to have_many :agency_people }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :agency_id }
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_length_of(:code).is_at_most(8) }
    context 'uniqueness of code within agency' do
      subject { FactoryBot.build(:branch) }
      it { is_expected.to validate_uniqueness_of(:code).scoped_to(:agency_id) }
    end
  end

  describe 'Branch' do
    it 'is valid with all required fields' do
      expect(Branch.new(code: '123', agency: FactoryBot.create(:agency)))
        .to be_valid
    end
    context 'is invalid' do
      let(:branch)  { FactoryBot.build(:branch, code: nil, agency: nil) }

      it 'without a code or agency' do
        branch.valid?
        expect(branch).to_not be_valid
        expect(branch.errors[:code]).to include("can't be blank")
        expect(branch.errors[:agency_id]).to include("can't be blank")
      end
      it 'with a code that exceeds max length' do
        branch.code = '123456789'
        branch.valid?
        expect(branch).to_not be_valid
        expect(branch.errors[:code])
          .to include('is too long (maximum is 8 characters)')
      end
      it 'with a non-unique code' do
        FactoryBot.create(:branch, code: '999', agency_id: 1)
        branch.code = '999'
        branch.agency_id = 1
        branch.valid?
        expect(branch).to_not be_valid
        expect(branch.errors[:code]).to include('has already been taken')
      end
    end
  end

  describe 'When branch is destroyed' do
    let(:person1) { FactoryBot.create(:agency_person) }
    let(:branch)  { person1.branch }
    let(:person2) { FactoryBot.create(:agency_person, branch: branch) }

    it 'associated address is destroyed' do
      address = branch.address
      expect(address).to_not be nil
      branch.destroy
      expect { Address.find(address.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'associated agency_people are nullified' do
      expect(branch.agency_people).to match_array([person1, person2])
      branch.destroy
      expect(AgencyPerson.find(person1.id).branch).to be nil
      expect(AgencyPerson.find(person2.id).branch).to be nil
    end
  end
end
