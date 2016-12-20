require "rails_helper"
include ServiceStubHelpers::Cruncher

RSpec.describe JobSeekerMailer, type: :mailer do

  describe 'Job developer assigned to job seeker' do
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

    let(:mail) { JobSeekerMailer.job_developer_assigned(job_seeker, job_developer) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Job developer assigned'
      expect(mail.to).to eq(["#{job_seeker.email}"])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end
    it "renders the body" do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text("has been assigned to you as your #{agency.name} Job Developer.")
    end

  end

  describe 'Case manager assigned to job seeker' do
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:case_manager)  { FactoryGirl.create(:case_manager, agency: agency) }
    let(:job_seeker)    { FactoryGirl.create(:job_seeker) }

    let(:mail) { JobSeekerMailer.case_manager_assigned(job_seeker, case_manager) }

    it "renders the headers" do
      expect(mail.subject).to eq 'Case manager assigned'
      expect(mail.to).to eq(["#{job_seeker.email}"])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end
    it "renders the body" do
      expect(mail).to have_body_text(case_manager.full_name(last_name_first: false))
      expect(mail).to have_body_text("has been assigned to you as your #{agency.name} Case Manager.")
    end

  end

  describe 'Job applied by job developer' do
    let(:agency)        { FactoryGirl.create(:agency) }
    let(:job_developer) { FactoryGirl.create(:job_developer, agency: agency) }
    let(:job_seeker)     { FactoryGirl.create(:job_seeker) }
    let(:job)            { FactoryGirl.create(:job) }
    let(:mail) { JobSeekerMailer.job_applied_by_job_developer(job_seeker, job_developer, job) }

    before do
      stub_cruncher_authenticate
      stub_cruncher_job_create
    end

    it "renders the headers" do
      expect(mail.subject).to eq 'Job applied by job developer'
      expect(mail.to).to eq(["#{job_seeker.email}"])
      expect(mail.from).to eq([ENV['ADMIN_EMAIL']])
    end
    it "renders the body" do
      expect(mail).to have_body_text(job_developer.full_name(last_name_first: false))
      expect(mail).to have_body_text("has submitted an application on your behalf to the job:")
    end
    it "includes link to show job" do
      expect(mail).to have_body_text(/#{job_url(id: 1)}/)
    end

  end

end
