require "rails_helper"
include ServiceStubHelpers::Cruncher

RSpec.describe AgencyMailer, type: :mailer do

  describe 'Job Seeker registered' do
    let!(:agency) { FactoryGirl.create(:agency) }
    let!(:agency_person) { FactoryGirl.create(:agency_person, agency: agency) }
    let!(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:mail) { AgencyMailer.job_seeker_registered(agency_person.email,
                                    job_seeker) }

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
    let!(:company) { FactoryGirl.create(:company) }
    let(:mail) { AgencyMailer.company_registered(agency_person.email,
                                    company) }

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

  describe 'Job seeker applied to job' do
    let!(:agency_person) { FactoryGirl.create(:agency_admin) }
    let!(:job_seeker)     { FactoryGirl.create(:job_seeker) }
    let!(:resume)     { FactoryGirl.create(:resume, job_seeker: job_seeker) }
    let!(:company) { FactoryGirl.create(:company) }
    let(:company_person) { FactoryGirl.create(:company_person, company: company) }
    let(:job)            { FactoryGirl.create(:job, company: company,
                                              company_person: company_person) }
    let!(:test_file) {'../fixtures/files/Admin-Assistant-Resume.pdf'}
    let(:application) do
      job.apply job_seeker
    end

    let(:mail) { AgencyMailer.job_seeker_applied(agency_person.email,
                                    application) }

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download test_file
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job seeker applied'
      expect(mail.to).to eq(["#{agency_person.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text("A job seeker has applied to this job:")
    end
    it "includes link to show job" do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it "includes link to show job seeker" do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Job Application accepted' do
    let(:job) { FactoryGirl.create(:job) }
    let(:job_developer) { FactoryGirl.create(:job_developer) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:app) { FactoryGirl.create(:job_application, job_seeker: job_seeker, job: job) }
    let(:mail) { AgencyMailer.job_application_accepted(job_developer.email, app) }

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job application accepted'
      expect(mail.to).to eq(["#{job_developer.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text("A job application is accepted:")
    end
    it "includes link to show job application" do
      expect(mail).to have_body_text(/#{application_url(id: 1)}/)
    end
  end

  describe 'Job Application rejected' do
    let(:job) { FactoryGirl.create(:job) }
    let(:job_developer) { FactoryGirl.create(:job_developer) }
    let(:job_seeker) { FactoryGirl.create(:job_seeker) }
    let(:app) { FactoryGirl.create(:job_application, job_seeker: job_seeker, job: job) }
    let(:mail) { AgencyMailer.job_application_rejected(job_developer.email, app) }

    before :each do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job application rejected'
      expect(mail.to).to eq(["#{job_developer.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text("A job application is rejected:")
    end
    it "includes link to show job application" do
      expect(mail).to have_body_text(/#{application_url(id: 1)}/)
    end
  end

  describe 'Job seeker assigned to job developer' do
    let(:job_developer) { FactoryGirl.create(:job_developer) }
    let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

    let(:mail) { AgencyMailer.job_seeker_assigned_jd(job_developer.email,
                                    job_seeker) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Job seeker assigned jd'
      expect(mail.to).to eq(["#{job_developer.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text("A job seeker has been assigned to you as Job Developer:")
    end
    it "includes link to show job seeker" do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'Job seeker assigned to case manager' do
    let(:case_manager)  { FactoryGirl.create(:case_manager) }
    let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

    let(:mail) { AgencyMailer.job_seeker_assigned_cm(case_manager.email,
                                    job_seeker) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Job seeker assigned cm'
      expect(mail.to).to eq(["#{case_manager.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text("A job seeker has been assigned to you as Case Manager:")
    end
    it "includes link to show job seeker" do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end

  describe 'New job posted' do

    let(:job)           { FactoryGirl.create(:job) }
    let(:job_developer) { FactoryGirl.create(:job_developer)}

    let(:mail) do
      allow(Pusher).to receive(:trigger)
      stub_cruncher_authenticate
      stub_cruncher_job_create
      AgencyMailer.job_posted(job_developer.email, job)
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job posted'
      expect(mail.to).to eq(["#{job_developer.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text(/A new job \(\n.*#{Regexp.quote(job.title)}.*\n\) has been posted for company: #{Regexp.quote(job.company.name)}\./)
    end
    it "includes link to show job" do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end

  describe 'Job revoked' do

    let(:job)           { FactoryGirl.create(:job) }
    let(:job_developer) { FactoryGirl.create(:job_developer)}

    let(:mail) do
      allow(Pusher).to receive(:trigger)
      stub_cruncher_authenticate
      stub_cruncher_job_create
      AgencyMailer.job_revoked(job_developer.email, job)
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job revoked'
      expect(mail.to).to eq(["#{job_developer.email}"])
      expect(mail.from).to eq(["from@example.com"])
    end
    it "renders the body" do
      expect(mail).to have_body_text(/A job \(\n.*#{Regexp.quote(job.title)}.*\n\) has been revoked for company: #{Regexp.quote(job.company.name)}\./)
    end
    it "includes link to show job" do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end

  describe 'Job Developer not assigned to JS applies to job' do
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:job_developer1) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:job_seeker)     { FactoryGirl.create(:job_seeker) }
    let(:job)            { FactoryGirl.create(:job) }
    let(:mail) { AgencyMailer.job_applied_by_other_job_developer(job_seeker, job_developer, job_developer1, job) }

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
      expect(mail.from).to eq(['from@example.com'])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text(/has submitted an application on behalf of/)
      expect(mail).to have_body_text(/Doe, John/)
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it "includes link to show job seeker" do
      expect(mail).to have_body_text(/#{job_seeker_url(id: 1)}/)
    end
  end
end
