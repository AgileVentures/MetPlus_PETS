require 'rails_helper'

include ServiceStubHelpers::Cruncher

RSpec.describe CompanyMailer, type: :mailer do
  describe 'registration cycle' do
    let(:company)         { FactoryBot.create(:company) }
    let(:company_person)  do
      FactoryBot.create(:company_person,
                        company: company)
    end
    let!(:agency) do
      agency = FactoryBot.build(:agency)
      agency.companies << company
      agency.save
      agency
    end

    context 'registration received' do
      let(:mail) { CompanyMailer.pending_approval(company, company_person) }

      it 'renders the headers' do
        expect(mail.subject).to eq 'Pending approval'
        expect(mail.to).to eq([company_person.email.to_s])
        expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
      end
      it 'renders the body' do
        expect(mail.body.encoded)
          .to match("Thank you for registering #{company.name} in PETS.")
      end
    end

    context 'registration approved' do
      let(:mail) { CompanyMailer.registration_approved(company, company_person) }

      it 'renders the headers' do
        expect(mail.subject).to eq 'Registration approved'
        expect(mail.to).to eq([company_person.email.to_s])
        expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
      end
      it 'renders the body' do
        expect(mail.body.encoded)
          .to match("Your registration of #{company.name} in PETS has been approved.")
      end
    end
  end

  describe 'Job application process' do
    let(:company) { FactoryBot.create(:company) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:resume) { FactoryBot.create(:resume, job_seeker: job_seeker) }
    let(:job) { FactoryBot.create(:job) }
    let(:job_application) do
      FactoryBot.create(:job_application,
                        job_seeker: job_seeker,
                        job: job)
    end
    let!(:test_file) { '../fixtures/files/Admin-Assistant-Resume.pdf' }

    let(:mail) do
      CompanyMailer.application_received(company,
                                         job_application, resume.id)
    end

    before do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download test_file
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job Application received'
      expect(mail.from).to eq [ENV['NOTIFICATION_EMAIL']]
      expect(mail.to).to eq [company.job_email]
    end

    it 'renders the body' do
      expect(mail)
        .to have_body_text('you have received an application')
    end

    it 'renders links for job title and job seeker' do
      expect(mail.body.encoded).to have_link('', href: job_url(job))
      expect(mail.body.encoded).to have_link('', href: job_seeker_url(job_seeker))
    end

    it 'renders the attachment' do
      expect(mail.attachments.length).to eq(1)
      expect(mail.attachments.last.filename).to eq(resume.file_name)
    end
  end
end
