Before('@selenium') do
  # This hook should be used for tests that include a modal dialog -
  # Poltergeist does not handle those cleanly.
  # This will run all @selenium tests in Firefox (non-headless).
  # If headless is desired then probably need to use gem selenium-webkit
  Capybara.javascript_driver = :selenium
end

After('@selenium') do
  Capybara.reset_sessions!
  Capybara.javascript_driver = :poltergeist
end