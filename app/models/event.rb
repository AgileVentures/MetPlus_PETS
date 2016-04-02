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

  def self.create(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER     # job seeker registered
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_REGISTER], evt_data)

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:JS_REGISTER], evt_data)

    when :COMP_REGISTER   # company registration request
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:COMP_REGISTER], evt_data)

      NotifyEmailJob.set(wait: @@delay.seconds).
                     perform_later(Agency.all_agency_people_emails,
                     EVT_TYPE[:COMP_REGISTER], evt_data)
    end
  end

end
