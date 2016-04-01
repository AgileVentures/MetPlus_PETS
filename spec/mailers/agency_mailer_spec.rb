require "rails_helper"

RSpec.describe AgencyMailer, type: :mailer do
  describe 'Job Seeker registered' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let!(:agency_person) { FactoryGirl.create(:agency_person, agency: agency) }
    let(:mail) { AgencyMailer.job_seeker_registered(agency_person.email,
                                    'John Smith', 1) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Job seeker registered'
      expect(mail.to).to eq(["#{agency_person.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).
          to have_body_text("A new job seeker has joined PETS:")
    end
    it "includes link to show job seeker" do
      expect(mail).
          to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Company registered' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let!(:agency_person) { FactoryGirl.create(:agency_person, agency: agency) }
    let(:mail) { AgencyMailer.company_registered(agency_person.email,
                                    'Gadgets, Inc.', 1) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Company registered'
      expect(mail.to).to eq(["#{agency_person.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).
          to have_body_text("A company has requested registration in PETS:")
    end
    it "includes link to show company" do
      expect(mail).
          to have_body_text(/#{company_url(id: 1)}/)
    end
  end

end
