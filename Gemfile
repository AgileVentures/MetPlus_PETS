source 'https://rubygems.org'

ruby '2.6.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.7.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.2'

gem 'webpacker', '~> 4.x'

gem 'haml'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '5.0.1'

gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.8'
# bundle exec rake doc:rails generates the API under doc/api.
group :doc do
  gem 'sdoc', '~> 1.0.0'
end

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.12'

gem 'devise', '~> 4.6.0'
gem 'devise_invitable', '~> 1.7.5'

gem 'figaro'

gem 'will_paginate'
gem 'bootstrap-will_paginate'

## Authorization gem
gem "pundit"

gem 'pusher'

gem 'js_cookie_rails'

gem 'active_record-acts_as'

gem 'delayed_job_active_record'

gem 'json'
gem 'rest-client'

gem 'cocoon'
gem 'pg'
# later we can strict the faker
# to staging && development
gem 'ffaker'
gem 'faker'

gem 'ransack'

gem 'mailgun_rails'

gem 'puma'

group :development do
  gem 'haml-rails'
  gem 'bullet'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.3'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # RSPEC testing
  gem 'rspec-rails', '~> 3.8'

  # Factory girl to add factories
  gem 'factory_bot_rails'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'jasmine'
  gem 'jasmine-jquery-rails'

  # gem 'phantomjs', require: 'phantomjs/poltergeist'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers', require: false
  gem 'email_spec'
  # gem 'poltergeist'
  gem 'codeclimate-test-reporter'
  gem 'launchy'
  gem 'selenium-webdriver' # Enables running cuke tests with browser (see env.rb)
  gem 'webmock'
  gem 'simplecov', :require => false
  gem 'rails-controller-testing'
end

gem 'airbrake', '~> 9.1'
group :production do
  gem 'rails_12factor'
end
