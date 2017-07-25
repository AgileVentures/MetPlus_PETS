Before('@javascript') do
  # Currently, poltergeist is preferred for headless tests
  Capybara.current_driver = :poltergeist
end

Before('@selenium_browser') do
  # Use this hook for running tests with visible browser ("non-headless")
  Capybara.current_driver = :selenium_browser
end

Before('@selenium') do
  # Use this hook for running headless tests using Chrome
  Capybara.current_driver = :selenium
end

After('@javascript, @selenium_browser, @selenium') do
  Capybara.reset_sessions!
  # force Chrome to quit after each scenario:
  page.driver.quit if Capybara.current_driver == :selenium ||
                      Capybara.current_driver == :selenium_browser
  Capybara.current_driver = :rack_test
end
