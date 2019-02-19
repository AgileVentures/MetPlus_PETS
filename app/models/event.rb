# frozen_string_literal: true

class Event
  include ActiveModel::Model
  require 'agency_person' # provide visibility to AR model methods

  def self.delay_seconds=(delay_seconds)
    @@delay = delay_seconds
  end

  def self.delay_seconds
    @@delay ||= 10
  end

  EVT_TYPE = { JS_REGISTER: 'js_registered',
               COMP_REGISTER: 'company_registered',
               COMP_APPROVED: 'company_registration_approved',
               COMP_DENIED: 'company_registration_denied',
               JS_APPLY: 'jobseeker_applied',
               JD_APPLY: 'job_applied_by_job_developer',
               OTHER_JD_APPLY: 'job_applied_by_other_job_developer',
               APP_ACCEPTED: 'job_application_accepted',
               APP_REJECTED: 'job_application_rejected',
               APP_PROCESSING: 'job_application_processing',
               JOB_POSTED: 'job_posted',
               JOB_REVOKED: 'job_revoked',
               JD_ASSIGNED_JS: 'jobseeker_assigned_jd',
               CM_ASSIGNED_JS: 'jobseeker_assigned_cm',
               JD_SELF_ASSIGN_JS: 'jd_self_assigned_js',
               CM_SELF_ASSIGN_JS: 'cm_self_assigned_js',
               CP_INTEREST_IN_JS: 'cp_interest_in_js' }.freeze

  # Add events as required below.  Each event may have business rules around
  # 1) who is to be notified of the event occurence, and/or 2) task(s)
  # to be created as a follow-up to the event.
  # If the business rules for an event are not obvious, make sure to
  # add comments explaining those rules.

  def self.create(evt_type, evt_obj)
    case evt_type
    when :JS_REGISTER
      evt_js_register(evt_obj)
    when :COMP_REGISTER
      evt_comp_register(evt_obj)
    when :COMP_APPROVED
      evt_comp_approved(evt_obj)
    when :COMP_DENIED
      evt_comp_denied(evt_obj)
    when :JS_APPLY
      evt_js_apply(evt_obj)
    when :JD_APPLY
      evt_jd_apply(evt_obj)
    when :APP_ACCEPTED
      evt_app_accepted(evt_obj)
    when :APP_REJECTED
      evt_app_rejected(evt_obj)
    when :APP_PROCESSING
      evt_app_processing(evt_obj)
    when :JOB_POSTED
      evt_job_posted(evt_obj)
    when :JOB_REVOKED
      evt_job_revoked(evt_obj)
    when :JD_ASSIGNED_JS
      evt_jd_assigned_js(evt_obj)
    when :CM_ASSIGNED_JS
      evt_cm_assigned_js(evt_obj)
    when :JD_SELF_ASSIGN_JS
      evt_jd_self_assigned_js(evt_obj)
    when :CM_SELF_ASSIGN_JS
      evt_cm_self_assigned_js(evt_obj)
    when :CP_INTEREST_IN_JS
      evt_cp_interest_in_js(evt_obj)
    end
  end

  def self.evt_js_register(evt_obj) # evt_obj = job seeker
    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JS_REGISTER],
                   id: evt_obj.id,
                   name: evt_obj.full_name(last_name_first: false))

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(Agency.all_agency_people_emails,
                                 EVT_TYPE[:JS_REGISTER],
                                 evt_obj)

    # MULTIPLE AGENCIES: the code below needs to change
    Task.new_js_registration_task(evt_obj, Agency.first)
  end

  def self.evt_comp_register(evt_obj) # evt_obj = company
    # Business rules:
    #    Notify agency people (pop-up and email)
    #    Send email to company contact
    #    Add task to review company registration
    Pusher.trigger('pusher_control',
                   EVT_TYPE[:COMP_REGISTER],
                   id: evt_obj.id, name: evt_obj.name)

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(Agency.all_agency_people_emails,
                                 EVT_TYPE[:COMP_REGISTER],
                                 evt_obj)

    CompanyMailerJob.set(wait: delay_seconds.seconds)
                    .perform_later(EVT_TYPE[:COMP_REGISTER],
                                   evt_obj,
                                   evt_obj.company_people[0])

    Task.new_review_company_registration_task(evt_obj, evt_obj.agencies[0])
  end

  def self.evt_comp_approved(evt_obj) # evt_obj = company
    # Business rules:
    #    Send email to company contact

    CompanyMailerJob.set(wait: delay_seconds.seconds)
                    .perform_later(EVT_TYPE[:COMP_APPROVED],
                                   evt_obj,
                                   evt_obj.company_people[0])
  end

  def self.evt_comp_denied(evt_obj) # evt_obj = struct(company, reason)
    # Business rules:
    #    Send email to company contact

    CompanyMailerJob.set(wait: delay_seconds.seconds)
                    .perform_later(EVT_TYPE[:COMP_DENIED],
                                   evt_obj.company,
                                   evt_obj.company.company_people[0],
                                   reason: evt_obj.reason)
  end

  def self.evt_js_apply(evt_obj) # evt_obj = job application
    # Business rules:
    #    Notify job seeker's case manager
    #    Notify job seeker's job developer
    #    Notify company contact associated with the job
    #    Create task for 'job application' (application to be reviewed)

    notify_list = notify_list_for_js_apply_event(evt_obj)

    unless notify_list.empty?
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_APPLY],
                     job_id: evt_obj.job.id,
                     js_id: evt_obj.job_seeker.id,
                     js_name: evt_obj.job_seeker.full_name(last_name_first: false),
                     notify_list: notify_list[0])
      NotifyEmailJob.set(wait: delay_seconds.seconds)
                    .perform_later(notify_list[1],
                                   EVT_TYPE[:JS_APPLY],
                                   evt_obj)
    end

    Task.new_review_job_application_task(evt_obj, evt_obj.job.company)
  end

  def self.evt_jd_apply(evt_obj) # evt_obj = job_app
    # Job is applied by job developer for his job seeker
    # Business rules:
    #    Notify job seeker
    #    Notify company contact associated with the job
    #    Create task for 'job application' (application to be reviewed)

    job_developer = evt_obj.try(:job_developer) || evt_obj.job_seeker.job_developer

    JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:JD_APPLY], evt_obj.job_seeker,
                                    job_developer, evt_obj.job)

    if job_developer != evt_obj.job_seeker.job_developer
      AgencyMailerJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:OTHER_JD_APPLY],
                                    evt_obj.job_seeker,
                                    evt_obj.job_seeker.job_developer,
                                    job_developer, evt_obj.job)
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:OTHER_JD_APPLY],
                     job_id: evt_obj.job.id,
                     js_user_id: evt_obj.job_seeker.user.id,
                     jd_id: job_developer.id,
                     jd_name: job_developer.full_name(last_name_first: false))
    else
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JD_APPLY],
                     job_id: evt_obj.job.id,
                     js_user_id: evt_obj.job_seeker.user.id)
    end

    if evt_obj.job.company_person
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_APPLY],
                     job_id: evt_obj.job.id,
                     js_id: evt_obj.job_seeker.id,
                     js_name: evt_obj.job_seeker.full_name(last_name_first: false),
                     notify_list: [evt_obj.job.company_person.user.id])

      NotifyEmailJob.set(wait: delay_seconds.seconds)
                    .perform_later([evt_obj.job.company_person.user.email],
                                   EVT_TYPE[:JS_APPLY],
                                   evt_obj)
    end

    Task.new_review_job_application_task(evt_obj, evt_obj.job.company)
  end

  def self.evt_app_accepted(evt_obj)
    # evt_obj = job application
    # Business rules:
    # Notify job seeker's job developer (email and popup)
    # Notify job seeker's case manager (email and popup)

    notify_list = []
    job_developer = evt_obj.job_seeker.job_developer
    case_manager = evt_obj.job_seeker.case_manager
    job_seeker = evt_obj.job_seeker
    if job_developer
      # if the case manager is the same as job developer for the same
      # job_seeker use the if statement for case manager to notify the agency person
      unless case_manager == job_developer
        notify_list << job_developer.user.email
        Pusher.trigger(
          'pusher_control',
          EVT_TYPE[:APP_ACCEPTED],
          id: evt_obj.id,
          ap_user_id: job_developer.user.id,
          job_title: evt_obj.job.title,
          js_name: job_seeker.full_name(last_name_first: false)
        )
      end
    end

    if case_manager
      notify_list << case_manager.user.email
      Pusher.trigger(
        'pusher_control',
        EVT_TYPE[:APP_ACCEPTED],
        id: evt_obj.id,
        ap_user_id: case_manager.user.id,
        job_title: evt_obj.job.title,
        js_name: job_seeker.full_name(last_name_first: false)
      )
    end

    unless notify_list.empty?
      NotifyEmailJob.set(wait: delay_seconds.seconds)
                    .perform_later(notify_list,
                                   EVT_TYPE[:APP_ACCEPTED],
                                   evt_obj)
    end
  end

  def self.evt_app_processing(evt_obj)
    # evt_obj = job application
    # Business rules:
    # Notify job seeker's job developer (email and popup)
    # Notify job seeker's case manager (email and popup)

    notify_list = []
    job_developer = evt_obj.job_seeker.job_developer
    case_manager = evt_obj.job_seeker.case_manager
    job_seeker = evt_obj.job_seeker
    if job_developer
      # if the case manager is the same as job developer for the same
      # job_seeker use the if statement for case manager to notify the agency person
      unless case_manager == job_developer
        notify_list << job_developer.user.email
        Pusher.trigger(
          'pusher_control',
          EVT_TYPE[:APP_PROCESSING],
          id: evt_obj.id,
          ap_user_id: job_developer.user.id,
          job_title: evt_obj.job.title,
          js_name: job_seeker.full_name(last_name_first: false)
        )
      end
    end

    if case_manager
      notify_list << case_manager.user.email
      Pusher.trigger(
        'pusher_control',
        EVT_TYPE[:APP_PROCESSING],
        id: evt_obj.id,
        ap_user_id: case_manager.user.id,
        job_title: evt_obj.job.title,
        js_name: job_seeker.full_name(last_name_first: false)
      )
    end

    unless notify_list.empty?
      NotifyEmailJob.set(wait: delay_seconds.seconds)
                    .perform_later(notify_list,
                                   EVT_TYPE[:APP_PROCESSING],
                                   evt_obj)
    end
  end

  def self.evt_app_rejected(evt_obj)
    # evt_obj = job application
    # Business rules:
    # Notify job seeker's job developer (email and popup)
    # Notify job seeker's case manager (email and popup)

    notify_list = []
    job_developer = evt_obj.job_seeker.job_developer
    case_manager = evt_obj.job_seeker.case_manager
    job_seeker = evt_obj.job_seeker

    if job_developer
      unless job_developer == case_manager
        notify_list << job_developer.user.email
        Pusher.trigger(
          'pusher_control',
          EVT_TYPE[:APP_REJECTED],
          id: evt_obj.id,
          ap_user_id: job_developer.user.id,
          job_title: evt_obj.job.title,
          js_name: job_seeker.full_name(last_name_first: false)
        )
      end
    end

    if case_manager
      notify_list << case_manager.user.email
      Pusher.trigger(
        'pusher_control',
        EVT_TYPE[:APP_REJECTED],
        id: evt_obj.id,
        ap_user_id: case_manager.user.id,
        job_title: evt_obj.job.title,
        js_name: job_seeker.full_name(last_name_first: false)
      )
    end

    unless notify_list.empty?
      NotifyEmailJob.set(wait: delay_seconds.seconds)
                    .perform_later(notify_list,
                                   EVT_TYPE[:APP_REJECTED],
                                   evt_obj)
    end
  end

  def self.evt_jd_assigned_js(evt_obj)
    # This event occurs when a job developer is assigned a job seeker,
    # by an agency admin.
    # evt_obj = struct(:job_seeker, :agency_person)
    # Business rules:
    #    Notify job developer (email and popup)
    #    Notify job seeker

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JD_ASSIGNED_JS],
                   js_id: evt_obj.job_seeker.id,
                   js_user_id: evt_obj.job_seeker.user.id,
                   js_name: evt_obj.job_seeker.full_name(last_name_first: false),
                   jd_name: evt_obj.agency_person.full_name(last_name_first: false),
                   jd_user_id: evt_obj.agency_person.user.id,
                   agency_name: evt_obj.agency_person.agency.name)

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(evt_obj.agency_person.email,
                                 EVT_TYPE[:JD_ASSIGNED_JS],
                                 evt_obj.job_seeker)

    JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:JD_ASSIGNED_JS],
                                    evt_obj.job_seeker, evt_obj.agency_person)
  end

  def self.evt_jd_self_assigned_js(evt_obj)
    # This event occurs when a job developer assigns himself to a job seeker.
    # evt_obj = struct(:job_seeker, :agency_person)
    # Business rules:
    #    Notify job seeker
    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JD_SELF_ASSIGN_JS],
                   js_user_id: evt_obj.job_seeker.user.id,
                   jd_name: evt_obj.agency_person.full_name(last_name_first: false),
                   agency_name: evt_obj.agency_person.agency.name)

    JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:JD_SELF_ASSIGN_JS],
                                    evt_obj.job_seeker, evt_obj.agency_person)
  end

  def self.evt_cm_self_assigned_js(evt_obj)
    # This event occurs when a case manager assigns himself to a job seeker.
    # evt_obj = struct(:job_seeker, :agency_person)
    # Business rules:
    #    Notify job seeker
    Pusher.trigger('pusher_control',
                   EVT_TYPE[:CM_SELF_ASSIGN_JS],
                   js_user_id: evt_obj.job_seeker.user.id,
                   cm_name: evt_obj.agency_person.full_name(last_name_first: false),
                   agency_name: evt_obj.agency_person.agency.name)

    JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:CM_SELF_ASSIGN_JS],
                                    evt_obj.job_seeker, evt_obj.agency_person)
  end

  def self.evt_cm_assigned_js(evt_obj)
    # This event occurs when a case manager is assigned a job seeker,
    # by an agency admin.
    # evt_obj = struct(:job_seeker, :agency_person)
    # Business rules:
    #    Notify case manager (email and popup)
    #    Notify job seeker

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:CM_ASSIGNED_JS],
                   js_id: evt_obj.job_seeker.id,
                   js_user_id: evt_obj.job_seeker.user.id,
                   js_name: evt_obj.job_seeker.full_name(last_name_first: false),
                   cm_name: evt_obj.agency_person.full_name(last_name_first: false),
                   cm_user_id: evt_obj.agency_person.user.id,
                   agency_name: evt_obj.agency_person.agency.name)

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(evt_obj.agency_person.email,
                                 EVT_TYPE[:CM_ASSIGNED_JS],
                                 evt_obj.job_seeker)

    JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                     .perform_later(EVT_TYPE[:CM_ASSIGNED_JS],
                                    evt_obj.job_seeker, evt_obj.agency_person)
  end

  def self.evt_job_posted(evt_obj)
    # evt_obj = struct(:job, :agency)
    # Business rules:
    #    Notify all job developers in agency (email and popup)

    job_developers = Agency.job_developers(evt_obj.agency)

    return if job_developers.empty?

    jd_ids    = job_developers.map { |jd| jd.user.id }.sort # for test purposes
    jd_emails = job_developers.map(&:email)

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JOB_POSTED],
                   job_id: evt_obj.job.id,
                   job_title: evt_obj.job.title,
                   company_name: evt_obj.job.company.name,
                   notify_list: jd_ids)

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(jd_emails,
                                 EVT_TYPE[:JOB_POSTED],
                                 evt_obj.job)
  end

  def self.evt_job_revoked(evt_obj)
    # evt_obj = struct(:job, :agency)
    # Notify all job developers in agency (email and popup)

    job_developers = Agency.job_developers(evt_obj.agency)

    return if job_developers.empty?

    jd_ids     = job_developers.map { |jd| jd.user.id }.sort
    jd_emails  = job_developers.map(&:email)

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JOB_REVOKED],
                   job_id: evt_obj.job.id,
                   job_title: evt_obj.job.title,
                   company_name: evt_obj.job.company.name,
                   notify_list: jd_ids)

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later(jd_emails,
                                 EVT_TYPE[:JOB_REVOKED],
                                 evt_obj.job)

    job_apps = evt_obj.job.job_applications

    return if job_apps.empty?

    js_ids = job_apps.map { |ja| ja.job_seeker.user.id }.sort
    js_list = job_apps.map(&:job_seeker)

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:JOB_REVOKED],
                   job_id: evt_obj.job.id,
                   job_title: evt_obj.job.title,
                   company_name: evt_obj.job.company.name,
                   notify_list: js_ids)

    js_list.each do |js|
      JobSeekerEmailJob.set(wait: delay_seconds.seconds)
                       .perform_later(EVT_TYPE[:JOB_REVOKED],
                                      js, evt_obj.job)
    end
  end

  def self.evt_cp_interest_in_js(evt_obj)
    # evt_obj = struct(:job, :company_person, :job_developer, :job_seeker)
    # Business rules:
    # Notify job developer of company person interest in job seeker
    # Add task for job developer to respond to company person

    Pusher.trigger('pusher_control',
                   EVT_TYPE[:CP_INTEREST_IN_JS],
                   jd_user_id: evt_obj.job_developer.user.id,
                   cp_id: evt_obj.company_person.id,
                   cp_name: evt_obj.company_person.full_name(last_name_first: false),
                   job_id: evt_obj.job.id,
                   job_title: evt_obj.job.title,
                   js_id: evt_obj.job_seeker.id,
                   js_name: evt_obj.job_seeker.full_name(last_name_first: false))

    NotifyEmailJob.set(wait: delay_seconds.seconds)
                  .perform_later([evt_obj.job_developer.email],
                                 EVT_TYPE[:CP_INTEREST_IN_JS],
                                 evt_obj.company_person,
                                 evt_obj.job_seeker,
                                 evt_obj.job)

    Task.new_company_interest_task(evt_obj.job_seeker,
                                   evt_obj.company_person.company,
                                   evt_obj.job,
                                   evt_obj.job_developer.agency)
  end

  def self.notify_list_for_js_apply_event(appl)
    # Returns an array containing two arrays.  The first such array contains
    # user ids, and the second email addresses of the people to be notified
    id_list    = []
    email_list = []

    if appl.job_seeker.case_manager
      id_list    << appl.job_seeker.case_manager.user.id
      email_list << appl.job_seeker.case_manager.user.email
    end

    if appl.job_seeker.job_developer &&
       !id_list.include?(appl.job_seeker.job_developer.user.id)
      id_list    << appl.job_seeker.job_developer.user.id
      email_list << appl.job_seeker.job_developer.user.email
    end

    if appl.job.company_person
      id_list    << appl.job.company_person.user.id
      email_list << appl.job.company_person.user.email
    end

    (id_list.empty? ? [] : [id_list, email_list])
  end
end
