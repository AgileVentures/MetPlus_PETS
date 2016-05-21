class Event
  include ActiveModel::Model
  require 'agency_person' # provide visibility to AR model methods

  def self.delay_seconds=(delay_seconds)
    @@delay = delay_seconds
  end

  def self.delay_seconds
    @@delay
  end

  EVT_TYPE = {JS_REGISTER:   'js_registered',
              COMP_REGISTER: 'company_registered',
              JS_APPLY:      'jobseeker_applied'}

  # Add events as required below.  Each event may have business rules around
  # 1) who is to be notified of the event occurence, and/or 2) task(s)
  # to be created as a follow-up to the event.
  # If the business rules for an event are not obvious, make sure to
  # add comments explaining those rules.

  def self.create(evt_type, evt_obj)
    case evt_type
    when :JS_REGISTER                       # evt_obj = job seeker
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_REGISTER],
                     {id: evt_obj.id,
                      name: evt_obj.full_name(last_name_first: false)})

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:JS_REGISTER],
                     evt_obj)

      # MULTIPLE AGENCIES: the code below needs to change
      Task.new_js_registration_task(evt_obj, Agency.first)

    when :COMP_REGISTER                     # evt_obj = company
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:COMP_REGISTER],
                     {id: evt_obj.id, name: evt_obj.name})

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:COMP_REGISTER],
                     evt_obj)

      Task.new_review_company_registration_task(evt_obj, evt_obj.agencies[0])

    when :JS_APPLY                          # evt_obj = job application
      # Business rules:
      #    Notify job seeker's case manager
      #    Notify job seeker's job developer
      #    Notify company contact associated with the job
      #    Create task for 'job application' (application to be reviewed)
      
      notify_list = notify_list_for_js_apply_event(evt_obj)

      unless notify_list.empty?
        Pusher.trigger('pusher_control',
                       EVT_TYPE[:JS_APPLY],
                       {job_id:  evt_obj.job.id,
                        js_id:   evt_obj.job_seeker.id,
                        js_name: evt_obj.job_seeker.full_name(last_name_first: false),
                        notify_list: notify_list[0]})

        NotifyEmailJob.set(wait: @@delay.seconds).
                       perform_later(notify_list[1],
                       EVT_TYPE[:JS_APPLY],
                       evt_obj)
      end

      Task.new_review_job_application_task(evt_obj.job, evt_obj.job.company)

    end
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

    return (id_list.empty? ? [] : [id_list, email_list])
  end

end
