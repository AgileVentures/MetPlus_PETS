require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  let(:company)         { FactoryGirl.create(:company) }
  let(:company_admin)   { FactoryGirl.create(:company_admin, company: company)}
  let(:company_contact) { FactoryGirl.create(:company_contact, company: company)}
  let(:agency)          { FactoryGirl.create(:agency) }
  let(:case_manager)    { FactoryGirl.create(:case_manager, agency: agency) }
  let(:job_developer)   { FactoryGirl.create(:job_developer, agency: agency) }
  let(:agency_admin)    { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:job_seeker)      { FactoryGirl.create(:job_seeker) }
  let(:job)             { FactoryGirl.create(:job, company: company) }
  let(:job_app)         { FactoryGirl.build(:job_application, job: job,
                                job_seeker: job_seeker, status: :active)}

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
      it 'success' do
        expect(helper.show_person_path job_seeker).to eq(job_seeker_path job_seeker)
      end
    end
    describe 'agency people as' do
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
      it 'success' do
        expect(helper.show_person_home_page_path job_seeker).to eq(home_job_seeker_path job_seeker)
      end
    end
    describe 'agency people as' do
      it 'job developer' do
        expect(helper.show_person_home_page_path job_developer).to eq(home_agency_person_path(job_developer))
      end
      it 'case manager' do
        expect(helper.show_person_home_page_path case_manager).to eq(home_agency_person_path(case_manager))
      end
      it 'agency admin' do
        expect(helper.show_person_home_page_path agency_admin).to eq(home_agency_person_path(agency_admin))
      end
    end
    describe 'company people as' do
      it 'company admin' do
        expect(helper.show_person_home_page_path company_admin).to eq(home_company_person_path company_admin)
      end
      it 'company contact' do
        expect(helper.show_person_home_page_path company_contact).to eq(home_company_person_path company_contact)
      end
    end
  end

  context '#status_desc for status description display' do

    describe 'job application' do

      it 'Status 0 should be Active' do
        job_app.status = 0
        expect(status_desc(job_app)).to eq 'Active'
      end
      it 'Status 1 should be Accepted' do
        job_app.status = 1
        expect(status_desc(job_app)).to eq 'Accepted'
      end
      it 'Status 2 should be Not Accepted' do
        job_app.status = 2
        expect(status_desc(job_app)).to eq 'Not Accepted'
      end
    end

    describe 'agency person' do
      let(:agency_person) { FactoryGirl.create(:agency_person) }

      it 'Status 0 should be Invited' do
        agency_person.status = 0
        expect(status_desc(agency_person)).to eq 'Invited'
      end
      it 'Status 1 should be Active' do
        agency_person.status = 1
        expect(status_desc(agency_person)).to eq 'Active'
      end
      it 'Status 2 should be Inactive' do
        agency_person.status = 2
        expect(status_desc(agency_person)).to eq 'Inactive'
      end
    end

    describe 'Company' do
      it 'Status 0 should be Pending Registration' do
        company.status = 0
        expect(status_desc(company)).to eq 'Pending Registration'
      end
      it 'Status 1 should be Active' do
        company.status = 1
        expect(status_desc(company)).to eq 'Active'
      end
      it 'Status 2 should be Inactive' do
        company.status = 2
        expect(status_desc(company)).to eq 'Inactive'
      end
      it 'Status 3 should be Registration Denied' do
        company.status = 3
        expect(status_desc(company)).to eq 'Registration Denied'
      end
    end

    describe 'company person' do
      it 'Status 0 should be Company Pending' do
        company_contact.status = 0
        expect(status_desc(company_contact)).to eq 'Company Pending'
      end
      it 'Status 1 should be Invited' do
        company_contact.status = 1
        expect(status_desc(company_contact)).to eq 'Invited'
      end
      it 'Status 2 should be Active' do
        company_contact.status = 2
        expect(status_desc(company_contact)).to eq 'Active'
      end
      it 'Status 3 should be Inactive' do
        company_contact.status = 3
        expect(status_desc(company_contact)).to eq 'Inactive'
      end
      it 'Status 4 should be Company Denied' do
        company_contact.status = 4
        expect(status_desc(company_contact)).to eq 'Company Denied'
      end
    end
  end
end
