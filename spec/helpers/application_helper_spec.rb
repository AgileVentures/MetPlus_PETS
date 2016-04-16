require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context 'single_line_address method' do
    it 'returns string for address' do
      address = FactoryGirl.build(:address, :state => "MI")
      expect(single_line_address(address)).
          to eq "#{address.street}, #{address.city}, MI #{address.zipcode}"
    end
    it 'return no-address for nil' do
      expect(single_line_address(nil)).
          to eq 'No Address'
    end
  end

  context '#full_title' do

   it "base title" do
     expect(helper.full_title()).to eq("MetPlus")
   end

   it "show page title" do
       expect(helper.full_title("Ruby on Rails")).to eq("Ruby on Rails | MetPlus")
   end

  end

  context '#show_person_path with' do
    describe 'job seeker' do
      let!(:job_seeker) {FactoryGirl.create(:job_seeker)}
      it 'success' do
        expect(helper.show_person_path job_seeker).to eq(job_seeker_path job_seeker)
      end
    end
    describe 'agency people as' do
      let!(:agency) {FactoryGirl.create(:agency)}
      let!(:case_manager) {FactoryGirl.create(:case_manager, :agency => agency)}
      let!(:job_developer) {FactoryGirl.create(:job_developer, :agency => agency)}
      let!(:agency_admin) {FactoryGirl.create(:agency_admin, :agency => agency)}
      it 'job developer' do
        expect(helper.show_person_path job_developer).to eq(agency_person_path job_developer)
      end
      it 'case manager' do
        expect(helper.show_person_path case_manager).to eq(agency_person_path case_manager)
      end
      it 'agency admin' do
        expect(helper.show_person_path agency_admin).to eq(agency_person_path agency_admin)
      end
    end
    describe 'company people as' do
      let!(:company) {FactoryGirl.create(:company)}
      let!(:company_admin) {FactoryGirl.create(:company_admin, :company => company)}
      let!(:company_contact) {FactoryGirl.create(:company_contact, :company => company)}
      it 'company admin' do
        expect(helper.show_person_path company_admin).to eq(company_person_path company_admin)
      end
      it 'company contact' do
        expect(helper.show_person_path company_contact).to eq(company_person_path company_contact)
      end
    end
  end

  context '#show_person_home_page_path with' do
    describe 'not logged in' do
      it 'success' do
        expect(helper.show_person_home_page_path nil).to eq(root_path)
      end
    end
    describe 'job seeker' do
      let!(:job_seeker) {FactoryGirl.create(:job_seeker)}
      it 'success' do
        expect(helper.show_person_home_page_path job_seeker).to eq(home_job_seeker_path job_seeker)
      end
    end
    describe 'agency people as' do
      let!(:agency) {FactoryGirl.create(:agency)}
      let!(:case_manager) {FactoryGirl.create(:case_manager, :agency => agency)}
      let!(:job_developer) {FactoryGirl.create(:job_developer, :agency => agency)}
      let!(:agency_admin) {FactoryGirl.create(:agency_admin, :agency => agency)}
      it 'job developer' do
        expect(helper.show_person_home_page_path job_developer).to eq(root_path)
      end
      it 'case manager' do
        expect(helper.show_person_home_page_path case_manager).to eq(root_path)
      end
      it 'agency admin' do
        expect(helper.show_person_home_page_path agency_admin).to eq(root_path)
      end
    end
    describe 'company people as' do
      let!(:company) {FactoryGirl.create(:company)}
      let!(:company_admin) {FactoryGirl.create(:company_admin, :company => company)}
      let!(:company_contact) {FactoryGirl.create(:company_contact, :company => company)}
      it 'company admin' do
        expect(helper.show_person_home_page_path company_admin).to eq(home_company_person_path company_admin)
      end
      it 'company contact' do
        expect(helper.show_person_home_page_path company_contact).to eq(home_company_person_path company_contact)
      end
    end
  end
end
