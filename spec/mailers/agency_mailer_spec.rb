require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe AgencyMailer, type: :mailer do
  describe 'Job Seeker registered' do
    let!(:agency) { FactoryBot.create(:agency) }
    let!(:agency_person) { FactoryBot.create(:agency_person, agency: agency) }
    let!(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:mail) do
      AgencyMailer.job_seeker_registered(agency_person.email,
                                         job_seeker)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job seeker registered'
      expect(mail.to).to eq([agency_person.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail)
        .to have_body_text('A new job seeker has joined PETS:')
    end
    it 'includes link to show job seeker' do
      expect(mail)
        .to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Company registered' do
    let!(:agency) { FactoryBot.create(:agency) }
    let!(:agency_person) { FactoryBot.create(:agency_person, agency: agency) }
    let!(:company) { FactoryBot.create(:company) }
    let(:mail) do
      AgencyMailer.company_registered(agency_person.email,
                                      company)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Company registered'
      expect(mail.to).to eq([agency_person.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail)
        .to have_body_text('A company has requested registration in PETS:')
    end
    it 'includes link to show company' do
      expect(mail).to have_body_text(/#{company_url(id: company.id)}/)
    end
  end

  describe 'Job seeker applied to job' do
    let!(:agency_person) { FactoryBot.create(:agency_admin) }
    let!(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:resume) { FactoryBot.create(:resume, job_seeker: job_seeker) }
    let!(:company) { FactoryBot.create(:company) }
    let(:company_person) { FactoryBot.create(:company_person, company: company) }
    let(:job)            do
      FactoryBot.create(:job, company: company,
                              company_person: company_person)
    end
    let!(:test_file) { '../fixtures/files/Admin-Assistant-Resume.pdf' }
    let(:application) do
      job.apply job_seeker
    end

    let(:mail) do
      AgencyMailer.job_seeker_applied(agency_person.email,
                                      application)
    end

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download test_file
      stub_cruncher_file_upload
      resume
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job seeker applied'
      expect(mail.to).to eq([agency_person.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text('A job seeker has applied to this job:')
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it 'includes link to show job seeker' do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Job Application accepted' do
    let(:job) { FactoryBot.create(:job) }
    let(:job_developer) { FactoryBot.create(:job_developer) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:app) { FactoryBot.create(:job_application, job_seeker: job_seeker, job: job) }
    let(:mail) { AgencyMailer.job_application_accepted(job_developer.email, app) }

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job application accepted'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text('A job application is accepted:')
    end
    it 'includes link to show job application' do
      expect(mail).to have_body_text(/#{application_url(id: 1)}/)
    end
  end

  describe 'Job Application rejected' do
    let(:job) { FactoryBot.create(:job) }
    let(:job_developer) { FactoryBot.create(:job_developer) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let(:app) { FactoryBot.create(:job_application, job_seeker: job_seeker, job: job) }
    let(:mail) { AgencyMailer.job_application_rejected(job_developer.email, app) }

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job application rejected'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text('A job application is rejected:')
    end
    it 'includes link to show job application' do
      expect(mail).to have_body_text(/#{application_url(id: 1)}/)
    end
  end

  describe 'Job seeker assigned to job developer' do
    let(:job_developer) { FactoryBot.create(:job_developer) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }

    let(:mail) do
      AgencyMailer.job_seeker_assigned_jd(job_developer.email,
                                          job_seeker)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job seeker assigned jd'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text('A job seeker has been assigned ' \
                                     'to you as Job Developer:')
    end
    it 'includes link to show job seeker' do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Job seeker assigned to case manager' do
    let(:case_manager)  { FactoryBot.create(:case_manager) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }

    let(:mail) do
      AgencyMailer.job_seeker_assigned_cm(case_manager.email,
                                          job_seeker)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job seeker assigned cm'
      expect(mail.to).to eq([case_manager.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text('A job seeker has been assigned ' \
                                     'to you as Case Manager:')
    end
    it 'includes link to show job seeker' do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'New job posted' do
    let(:job)           { FactoryBot.create(:job) }
    let(:job_developer) { FactoryBot.create(:job_developer) }

    let(:mail) do
      AgencyMailer.job_posted(job_developer.email, job)
    end

    before(:each) do
      allow(Pusher).to receive(:trigger)
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job posted'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(/A new job \(\n.*#{job.title}.*\n\)/)
      expect(mail).to have_body_text(/has been posted for company: #{job.company.name}/)
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end

  describe 'Job revoked' do
    let(:job)           { FactoryBot.create(:job) }
    let(:job_developer) { FactoryBot.create(:job_developer) }

    let(:mail) do
      allow(Pusher).to receive(:trigger)
      stub_cruncher_authenticate
      stub_cruncher_job_create
      AgencyMailer.job_revoked(job_developer.email, job)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job revoked'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(/A job \(\n.*#{Regexp.quote(job.title)}.*\n\) has been revoked for company: #{Regexp.quote(job.company.name)}\./)
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end

  describe 'Job Developer not assigned to JS applies to job' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:job_developer1) { FactoryBot.create(:job_developer, agency: agency) }
    let(:job_seeker)     { FactoryBot.create(:job_seeker) }
    let(:job)            { FactoryBot.create(:job) }
    let(:mail) do
      AgencyMailer.job_applied_by_other_job_developer(job_seeker,
                                                      job_developer,
                                                      job_developer1, job)
    end
    before do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end
    before(:each) do
      job_seeker.assign_job_developer job_developer, agency
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job applied by other job developer'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text(/has submitted an application on behalf of/)
      expect(mail).to have_body_text(/Doe, John/)
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it 'includes link to show job seeker' do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Company interested in job seeker' do
    let(:agency)         { FactoryBot.create(:agency) }
    let(:job_developer)  { FactoryBot.create(:job_developer, agency: agency) }
    let(:job_seeker)     { FactoryBot.create(:job_seeker) }
    let(:job)            { FactoryBot.create(:job) }
    let(:company_person) { FactoryBot.create(:company_person) }
    let(:mail) do
      AgencyMailer.company_interest_in_job_seeker(job_developer.email,
                                                  company_person,
                                                  job_seeker, job)
    end
    before do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Company interest in job seeker'
      expect(mail.to).to eq([job_developer.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(company_person.full_name(last_name_first: false))
      expect(mail).to have_body_text(/as indicated interest in job seeker/)
      expect(mail).to have_body_text(job_seeker.full_name(last_name_first: false))
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it 'includes link to show job seeker' do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
    it 'includes link to show company person' do
      expect(mail).to have_body_text(/#{company_person_url(id: 1)}/)
    end
  end
end
