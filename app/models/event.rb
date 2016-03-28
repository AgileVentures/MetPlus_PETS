class Event
  include ActiveModel::Model

  def self.create(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER     # job seeker registered
      Pusher.trigger('pusher_control', 'js_registered', evt_data)
    when :COMP_REGISTER   # company registration request
      Pusher.trigger('pusher_control', 'company_registered', evt_data)
    end
  end
  
end
