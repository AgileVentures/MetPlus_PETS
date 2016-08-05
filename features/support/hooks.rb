Before('@selenium') do
  # This hook should be used for tests that include a modal dialog -
  # Poltergeist does not handle those cleanly.
  # This will run all @selenium tests in Firefox (non-headless).
  # If headless is desired then probably need to use gem selenium-webkit
  Capybara.javascript_driver = :selenium
end

Before('@javascript') do
  Capybara.current_driver = :poltergeist
end

After('@selenium') do
  Capybara.reset_sessions!
  Capybara.javascript_driver = :poltergeist
end

After('@javascript') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end

AfterStep('@pause') do
  print "Press Return to continue"
  STDIN.getc
end