module PusherManager

  def self.trigger_event(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER
      Pusher.trigger('pusher_control', 'js_registered', evt_data)
    end
  end
end
