ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'rubygems'
require 'rails/commands/server'

module Rails
  class Server
    alias :default_options_bk :default_options
    def default_options
      # Change the default property of HOST to 0.0.0.0
      # currently it is set to 127.0.0.1
      default_options_bk.merge!(Host: '0.0.0.0')
    end
  end
end
