require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobSeekerMailer, type: :mailer do
  describe 'Job developer assigned to job seeker' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }

    let(:mail) { JobSeekerMailer.job_developer_assigned(job_seeker, job_developer) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job developer assigned'
      expect(mail.to).to eq([job_seeker.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text(
        "has been assigned to you as your #{agency.name} Job Developer."
      )
    end
  end

  describe 'Case manager assigned to job seeker' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:case_manager)  { FactoryBot.create(:case_manager, agency: agency) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }

    let(:mail) { JobSeekerMailer.case_manager_assigned(job_seeker, case_manager) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Case manager assigned'
      expect(mail.to).to eq([job_seeker.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(case_manager.full_name(last_name_first: false))
      expect(mail).to have_body_text(
        "has been assigned to you as your #{agency.name} Case Manager."
      )
    end
  end

  describe 'Job applied by job developer' do
    let(:agency)        { FactoryBot.create(:agency) }
    let(:job_developer) { FactoryBot.create(:job_developer, agency: agency) }
    let(:job_seeker)    { FactoryBot.create(:job_seeker) }
    let(:job)           { FactoryBot.create(:job) }
    let(:mail) do
      JobSeekerMailer.job_applied_by_job_developer(job_seeker, job_developer, job)
    end

    before do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job applied by job developer'
      expect(mail.to).to eq([job_seeker.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text(
        'has submitted an application on your behalf to the job:'
      )
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end

  describe 'Job revoked' do
    let(:job) { FactoryBot.create(:job) }
    let(:job_seeker) { FactoryBot.create(:job_seeker) }
    let!(:resume)      { FactoryBot.create(:resume, job_seeker: job_seeker) }

    let(:mail) do
      allow(Pusher).to receive(:trigger)
      stub_cruncher_authenticate
      stub_cruncher_job_create
      stub_cruncher_file_download("files/#{resume.file_name}")
      job.apply job_seeker
      JobSeekerMailer.job_revoked(job_seeker, job)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Job revoked'
      expect(mail.to).to eq([job_seeker.email.to_s])
      expect(mail.from).to eq([ENV['NOTIFICATION_EMAIL']])
    end
    it 'renders the body' do
      expect(mail).to have_body_text(/This is to let you know that a job that you had /)
      expect(mail).to have_body_text(/applied to has been removed and/)
      expect(mail).to have_body_text(/thus is no longer active/)
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
    it 'includes link to show job' do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end
  end
end
