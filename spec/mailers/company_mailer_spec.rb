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

  describe 'Job application process' do

    let!(:company) { FactoryGirl.create(:company) }
    let!(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let!(:resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let!(:job_application) {
      FactoryGirl.create(:job_application,
        job_seeker: job_seeker,
        job: FactoryGirl.create(:job)
    )}

    let!(:mail) {
      CompanyMailer.application_received( company,
          job_application,
          File.new("#{Rails.root}/spec/fixtures/files/#{resume.file_name}").path)
    }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job Application received'
      expect(mail.from).to eq (["from@example.com"])
      expect(mail.to).to eq ([company.job_email])
    end

    it 'renders the body' do
      expect(mail).
      to have_body_text("you have received a job application for the job title #{job_application.job.title }")
    end

    it 'renders the attachment' do
      expect(mail.attachments.length).to eq(1)
      expect(mail.attachments.last.filename).to eq(resume.file_name)
    end

  end

end
