require 'rails_helper'
require 'agency_mailer'
include ServiceStubHelpers::Cruncher

RSpec.describe Event, type: :model do
  let!(:agency)        { FactoryGirl.create(:agency) }
  let(:agency_admin)   { FactoryGirl.create(:agency_admin) }
  let!(:job_developer)  { FactoryGirl.create(:job_developer, agency: agency) }
  let!(:case_manager)   { FactoryGirl.create(:case_manager, agency: agency) }
  let!(:job_seeker) do
    js = FactoryGirl.create(:job_seeker)
    js.assign_job_developer(job_developer, agency)
    js.assign_case_manager(case_manager, agency)
    js
  end
  
  let!(:resume) { FactoryGirl.create(:resume, job_seeker: job_seeker) }
  let(:company)        { FactoryGirl.create(:company, agencies: [agency]) }
  let!(:company_person) { FactoryGirl.create(:company_person, company: company) }
  let(:job)            { FactoryGirl.create(:job, company: company,
                                            company_person: company_person) }
  let(:job_wo_cp)      { FactoryGirl.create(:job, company: company,
                                            company_person: nil) }

  let(:evt_obj_class) { Struct.new(:job_seeker, :agency_person) }
  let(:evt_obj_jd)    { evt_obj_class.new(job_seeker, job_developer) }
  let(:evt_obj_cm)    { evt_obj_class.new(job_seeker, case_manager) }

  let(:evt_obj_jobpost_class) { Struct.new(:job, :agency) }
  let(:evt_obj_jobpost) { evt_obj_jobpost_class.new(job, agency) }

  let(:application) { job.apply job_seeker }
  let(:application_wo_cp) { job_wo_cp.apply job_seeker}

  let(:testfile_resume) { 'files/Admin-Assistant-Resume.pdf'}

  before(:each) do
    allow(Pusher).to receive(:trigger)  # stub and spy on 'Pusher'
    stub_cruncher_authenticate
    stub_cruncher_job_create

    3.times do |n|
      FactoryGirl.create(:agency_person, agency: agency)
    end
  end

  describe 'js_registered event' do
    it 'triggers a Pusher message' do
      Event.create(:JS_REGISTER, job_seeker)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'js_registered',
                         {name: job_seeker.full_name(last_name_first: false),
                          id: job_seeker.id})
    end

    it 'sends event notification email' do
      expect { Event.create(:JS_REGISTER, job_seeker) }.
                    to change(all_emails, :count).by(+1)
    end

    it 'creates two tasks' do
      expect { Event.create(:JS_REGISTER, job_seeker) }.
                    to change(Task, :count).by(+2)
    end
  end

  describe 'company_registered event' do
    it 'triggers a Pusher message' do
      Event.create(:COMP_REGISTER, company)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'company_registered',
                         {name: company.name, id: company.id})
    end

    it 'sends event notification email to company person and agency people' do
      expect { Event.create(:COMP_REGISTER, company) }.
                    to change(all_emails, :count).by(+2)
    end

    it 'creates one task' do
      expect { Event.create(:COMP_REGISTER, company) }.
                    to change(Task, :count).by(+1)
    end
  end

  describe 'company_registration_approved event' do
    it 'sends approval notification email to company person' do
      expect { Event.create(:COMP_APPROVED, company) }.
                    to change(all_emails, :count).by(+1)
    end
  end

  describe 'company_registration_denied event' do
    it 'sends denial notification email to company person' do
      obj = Struct.new(:company, :reason).new
      obj.company = company
      obj.reason = 'We are unable to accept new partners at this time'
      expect { Event.create(:COMP_DENIED, obj) }.
                    to change(all_emails, :count).by(+1)
    end
  end

  describe 'jobseeker_applied event' do
    before do
      stub_cruncher_authenticate
      stub_cruncher_file_download(testfile_resume)
    end

    it 'triggers a Pusher message' do
      Event.create(:JS_APPLY, application)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'jobseeker_applied',
                         {job_id:  job.id,
                          js_id:   job_seeker.id,
                          js_name: job_seeker.full_name(last_name_first: false),
                          notify_list: [job_seeker.case_manager.user.id, job_seeker.job_developer.user.id, company_person.user.id]})
    end

    it 'sends event notification email and application received email' do
      expect { Event.create(:JS_APPLY, application) }.
                    to change(all_emails, :count).by(+2)
    end

    it 'creates one task' do
      expect { Event.create(:JS_APPLY, application) }.
                    to change(Task, :count).by(+1)
    end
  end

  describe 'job_applied_by_job_developer event' do

    before do
        stub_cruncher_authenticate
        stub_cruncher_file_download  testfile_resume
    end

    describe 'job without company person' do
      it 'triggers a Pusher message to Job Seeker' do
        Event.create(:JD_APPLY, application_wo_cp)
        expect(Pusher).to have_received(:trigger).
                      with('pusher_control',
                           'job_applied_by_job_developer',
                           {job_id:  job_wo_cp.id,
                            js_user_id:   job_seeker.user.id})
      end

      it 'sends event notification email to Job seeker' do
        expect { Event.create(:JD_APPLY, application_wo_cp) }.
                      to change(all_emails, :count).by(+2)
      end

      it 'creates one task' do
        expect { Event.create(:JD_APPLY, application_wo_cp) }.
                      to change(Task, :count).by(+1)
      end
    end

    describe 'job with company person' do
      it 'triggers a Pusher message to Job Seeker' do
        Event.create(:JD_APPLY, application)
        expect(Pusher).to have_received(:trigger).
                      with('pusher_control',
                           'job_applied_by_job_developer',
                           {job_id:  job.id,
                            js_user_id:   job_seeker.user.id})
      end

      it 'triggers a Pusher message to Company Person' do
        Event.create(:JD_APPLY, application)
        expect(Pusher).to have_received(:trigger).
                      with('pusher_control',
                           'jobseeker_applied',
                           {job_id:  job.id,
                            js_id:   job_seeker.id,
                            js_name: job_seeker.full_name(last_name_first: false),
                            notify_list: [company_person.user.id]})
      end

      it 'sends event notification email to Job seeker and company person' do
        expect { Event.create(:JD_APPLY, application) }.
                      to change(all_emails, :count).by(+3)
      end

      it 'creates one task' do
        expect { Event.create(:JD_APPLY, application) }.
                      to change(Task, :count).by(+1)
      end
    end
  end
  describe 'job_application_accepted event' do

    before do
      stub_cruncher_authenticate
      stub_cruncher_file_download(testfile_resume)
    end

    it 'triggers Pusher message to primary job developer' do
      Event.create(:APP_ACCEPTED, application)
      expect(Pusher).to have_received(:trigger).
                        with('pusher_control',
                             'job_application_accepted',
                             {id: application.id,
                              ap_user_id: application.job_seeker.job_developer.user.id,
                              job_title: job.title,
                              js_name: application.job_seeker.full_name(last_name_first: false)
                              })
    end

    it 'triggers Pusher message to case manager' do
      Event.create(:APP_ACCEPTED, application)
      expect(Pusher).to have_received(:trigger).
                        with('pusher_control',
                             'job_application_accepted',
                             {id: application.id,
                              ap_user_id: application.job_seeker.case_manager.user.id,
                              job_title: job.title,
                              js_name: application.job_seeker.full_name(last_name_first: false)
                              })
    end
    
    it 'sends a notification email to job developer and case manager' do
      expect { Event.create(:APP_ACCEPTED, application) }.
                    to change(all_emails, :count).by(+2)
    end
  end

  describe 'jobseeker_assigned_jd event' do

    it 'triggers Pusher messages to job developer and job seeker' do
      Event.create(:JD_ASSIGNED_JS, evt_obj_jd)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'jobseeker_assigned_jd',
                         {js_id:   job_seeker.id,
                          js_user_id: job_seeker.user.id,
                          js_name: job_seeker.full_name(last_name_first: false),
                          jd_name: job_developer.full_name(last_name_first: false),
                          jd_user_id: job_developer.user.id,
                          agency_name: job_developer.agency.name})
    end

    it 'sends event notification emails to job developer and job seeker' do
      expect { Event.create(:JD_ASSIGNED_JS, evt_obj_jd) }.
                    to change(all_emails, :count).by(+2)
    end

  end

  describe 'jobseeker_assigned_cm event' do

    it 'triggers Pusher messages to case manager and job seeker' do
      Event.create(:CM_ASSIGNED_JS, evt_obj_cm)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'jobseeker_assigned_cm',
                         {js_id:   job_seeker.id,
                          js_user_id: job_seeker.user.id,
                          js_name: job_seeker.full_name(last_name_first: false),
                          cm_name: case_manager.full_name(last_name_first: false),
                          cm_user_id: case_manager.user.id,
                          agency_name: job_developer.agency.name})
    end

    it 'sends event notification emails to case manager and job seeker' do
      expect { Event.create(:CM_ASSIGNED_JS, evt_obj_cm) }.
                    to change(all_emails, :count).by(+2)
    end
  end

  describe 'job_posted event' do

    it 'triggers a Pusher message' do
      Event.create(:JOB_POSTED, evt_obj_jobpost)

      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'job_posted',
                         {job_id:    job.id,
                          job_title: job.title,
                          company_name: company.name,
                          notify_list: [job_developer.user.id]})
    end

    it 'sends event notification email' do
      expect { Event.create(:JOB_POSTED, evt_obj_jobpost) }.
                    to change(all_emails, :count).by(+1)
    end
  end

  describe 'job_revoked event' do

    it 'triggers mass Pusher message' do
      Event.create(:JOB_REVOKED, evt_obj_jobpost)

      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'job_revoked',
                         {job_id: job.id,
                          job_title: job.title,
                          company_name: company.name,
                          notify_list: [job_developer.user.id]})
    end

    it 'sends mass event notification email' do
      expect { Event.create(:JOB_REVOKED, evt_obj_jobpost) }.
                    to change(all_emails, :count).by(+1)
    end
  end

  describe 'jd_self_assigned_js event' do

    it 'triggers Pusher message to job seeker' do
      Event.create(:JD_SELF_ASSIGN_JS, evt_obj_jd)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'jd_self_assigned_js',
                         {js_user_id: job_seeker.user.id,
                          jd_name: job_developer.full_name(last_name_first: false),
                          agency_name: job_developer.agency.name})
    end

    it 'sends event notification email to job seeker' do
      expect { Event.create(:JD_SELF_ASSIGN_JS, evt_obj_jd) }.
                    to change(all_emails, :count).by(+1)
    end
  end

  describe 'cm_self_assigned_js event' do

    it 'triggers Pusher message to job seeker' do
      Event.create(:CM_SELF_ASSIGN_JS, evt_obj_cm)
      expect(Pusher).to have_received(:trigger).
                    with('pusher_control',
                         'cm_self_assigned_js',
                         {js_user_id: job_seeker.user.id,
                          cm_name: case_manager.full_name(last_name_first: false),
                          agency_name: case_manager.agency.name})
    end

    it 'sends event notification email to job seeker' do
      expect { Event.create(:CM_SELF_ASSIGN_JS, evt_obj_jd) }.
                    to change(all_emails, :count).by(+1)
    end
  end

end
