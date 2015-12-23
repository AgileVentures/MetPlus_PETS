require 'rails_helper'

RSpec.describe Agency, type: :model do
  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:agency)).to be_valid
    end
  end
  
  describe 'Associations' do
    it { is_expected.to have_many :agency_people }
    it { is_expected.to have_many :branches }
    it { is_expected.to have_and_belong_to_many :companies }
  end
  
  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :website }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :fax }
    it { is_expected.to have_db_column :description }
  end
  
  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of :website }
    it { is_expected.to validate_length_of(:website).is_at_most(200) }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :email }
  end
  
  describe 'Agency model' do
    it 'is valid with all required fields' do
      expect(Agency.new(name: 'Agency', website: 'myurl.com',
                        phone: '000-123-4567', email: 'agency@mail.com')).to be_valid
    end
    it 'is invalid without a name, website, phone or email' do
      agency = Agency.new()
      agency.valid?
      expect(agency.errors[:name]).to include("can't be blank")
      expect(agency.errors[:website]).to include("can't be blank")
      expect(agency.errors[:phone]).to include("can't be blank")
      expect(agency.errors[:email]).to include("can't be blank")
    end
  end
  
  describe 'Agency management' do
    let(:agency) { FactoryGirl.create(:agency) }
    let!(:aa_person1) do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let!(:aa_person2) do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:AA])
      $person.save
      $person
    end
    let(:jd_person) do
      $person = FactoryGirl.build(:agency_person, agency: agency)
      $person.agency_roles << FactoryGirl.create(:agency_role, 
                                      role: AgencyRole::ROLE[:JD])
      $person.save
      $person
    end
    
    it 'identifies agency admins' do
      expect(Agency.agency_admins(agency)).to eq [aa_person1, aa_person2]
    end
    
    it 'identifies agency' do
      expect(Agency.this_agency(jd_person)).to eq agency
      expect(Agency.this_agency(aa_person1)).to eq agency
    end
  end
  
end
