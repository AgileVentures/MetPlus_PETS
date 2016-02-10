module PusherManager

  def trigger_event(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER
      Pusher.trigger('pusher_test', 'js_register', evt_data)
    end
  end
end
