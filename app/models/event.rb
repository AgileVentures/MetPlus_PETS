class Event
  include ActiveModel::Model
  require 'agency_person' # provide visibility to AR model methods

  EVT_TYPE = {JS_REGISTER:   'js_registered',
              COMP_REGISTER: 'company_registered'}

  def self.create(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER     # job seeker registered
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:JS_REGISTER], evt_data)

      # Send notification email to all agency personnel
      agency_emails = Agency.all_agency_people_emails
      AgencyMailer.job_seeker_registered(agency_emails, evt_data[:name],
                    evt_data[:id]).deliver_later

    when :COMP_REGISTER   # company registration request
      Pusher.trigger('pusher_control',
                     EVT_TYPE[:COMP_REGISTER], evt_data)

      # Send notification email to all agency personnel
      agency_emails = Agency.all_agency_people_emails
      AgencyMailer.company_registered(agency_emails, evt_data[:name],
                    evt_data[:id]).deliver_later
    end
  end

end
