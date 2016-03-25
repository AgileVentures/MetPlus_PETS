class Event
  include ActiveModel::Model
  require 'pusher'

  @@pusher_client = nil

  def self.create(evt_type, evt_data)
    case evt_type
    when :JS_REGISTER     # job seeker registered
      get_pusher_client.trigger('pusher_control', 'js_registered', evt_data)
    when :COMP_REGISTER   # company registration request
      get_pusher_client.trigger('pusher_control', 'company_registered', evt_data)
    end
  end

  private

  def self.get_pusher_client
    @@pusher_client = @@pusher_client || Pusher::Client.new(
      app_id: ENV['PUSHER_APP_ID'],
      key:    ENV['PUSHER_APP_KEY'],
      secret: ENV['PUSHER_APP_SECRET'])
  end

end
