Before('@javascript') do
  Capybara.current_driver = :poltergeist
end

Before('@selenium') do
  # Note that poltergeist is the preferred web driver for tests that
  # require javascript support
  Capybara.javascript_driver = :selenium
end

After('@selenium') do
  Capybara.reset_sessions!
  Capybara.javascript_driver = :poltergeist
end

After('@javascript') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end
