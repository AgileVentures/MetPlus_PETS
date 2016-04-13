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
              COMP_REGISTER: 'company_registered'}

  def self.create(evt_type, evt_obj)
    case evt_type
    when :JS_REGISTER     # job seeker registered
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_REGISTER],
                     {id: evt_obj.id,
                      name: evt_obj.full_name(last_name_first: false)})

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:JS_REGISTER],
                     {id: evt_obj.id,
                      name: evt_obj.full_name(last_name_first: false)})

      # MULTIPLE AGENCIES: the code below needs to change
      Task.new_js_registration_task(evt_obj, Agency.first)

    when :COMP_REGISTER   # company registration request
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:COMP_REGISTER],
                     {id: evt_obj.id, name: evt_obj.name})

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:COMP_REGISTER],
                     {id: evt_obj.id, name: evt_obj.name})

      Task.new_review_company_registration_task(evt_obj, evt_obj.agencies[0])
    end
  end

end
