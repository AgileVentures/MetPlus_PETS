require "rails_helper"

RSpec.describe CompanyMailer, type: :mailer do
  describe "registration cycle" do
    let(:company)         { FactoryGirl.create(:company) }
    let(:company_person)  { FactoryGirl.create(:company_person,
                                      company: company)}
    let!(:agency) do
      $agency = FactoryGirl.build(:agency)
      $agency.companies << company
      $agency.save
      $agency
    end

    context 'registration received' do
      let(:mail) { CompanyMailer.pending_approval(company, company_person) }

      it "renders the headers" do
        expect(mail.subject).to eq 'Pending approval'
        expect(mail.to).to eq(["#{company_person.email}"])
        expect(mail.from).to eq(["from@example.com"])
      end
      it "renders the body" do
        expect(mail.body.encoded).
              to match("Thank you for registering #{company.name} in PETS.")
      end
    end

    context 'registration approved' do
      let(:mail) { CompanyMailer.registration_approved(company, company_person) }

      it "renders the headers" do
        expect(mail.subject).to eq 'Registration approved'
        expect(mail.to).to eq(["#{company_person.email}"])
        expect(mail.from).to eq(["from@example.com"])
      end
      it "renders the body" do
        expect(mail.body.encoded).
              to match("Your registration of #{company.name} in PETS has been approved.")
      end
    end
  end

end
