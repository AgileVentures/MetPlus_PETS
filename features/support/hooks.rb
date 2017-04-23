
Before('@javascript') do
  Capybara.current_driver = :poltergeist
end

Before('@selenium') do
  # Note that poltergeist is the preferred web driver for tests that
  # require javascript support
  Capybara.javascript_driver = :selenium
end

Before('~@mailgun') do
  stub_request(:get, %r{^#{EmailValidateService.service_url}/validate?.*})
        .to_return do |request|
          address = request.uri.to_s.split('?').last.split('=').last
          local_part, domain = address.split('@')
          hash = { address: "#{address}",
                   did_you_mean: "null",
                   is_valid: true,
                   parts: {    
                    display_name: "null",
                    domain: "#{domain}",
                    local_part: "#{local_part}"
                   }
                  }
         { body: hash.to_json }
        end
end

After('@selenium') do
  Capybara.reset_sessions!
  Capybara.javascript_driver = :poltergeist
end

After('@javascript') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end
