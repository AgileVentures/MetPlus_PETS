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
    it { is_expected.to have_many(:status_changes).dependent(:destroy) }
    describe 'dependent: :destroy and dependent: :nullify' do
      let(:company_person) { FactoryBot.create(:pending_first_company_admin) }
      let(:job) { FactoryBot.create(:job) }
      it 'destroys status_changes with association when company_person is destroyed' do
        company_person.active
        statuses = company_person.status_changes
        expect { company_person.destroy }.to \
          change { statuses.count }.from(1).to(0).and \
            change { StatusChange.count }.by(-1)
      end
      it 'nullifys job\'s foreign key when company_person is destroyed' do
        company_person = job.company_person
        foreign = job.company_person_id
        expect { company_person.destroy }.to \
          change { Job.find_by(company_person_id: foreign).nil? } \
          .from(false).to(true).and \
            change { Job.count }.by(0)
      end
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
