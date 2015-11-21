And(/^I (?:login|am logged in) as "([^"]*)" with password "([^"]*)"$/) do |email, password|
  step %{I click the "Log In" link}
  step %{I fill in "user_email" with "#{email}"}
  step %{I fill in "user_password" with "#{password}"}
  step %{I click "Log in" button}
end
