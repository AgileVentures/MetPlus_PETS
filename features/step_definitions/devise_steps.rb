And(/^I (?:login|am logged in) as "([^"]*)" with password "([^"]*)"$/) do |email, password|
  step %{I click the "Log In" link}
  step %{I fill in "user_email" with "#{email}"}
  step %{I fill in "user_password" with "#{password}"}
  step %{I click "Log in" button}
end

Given(/^I am logged in as agency admin$/) do
  step %{I am on the home page}
  step %{I login as "aa@metplus.org" with password "qwerty123"}
end

Then(/^I log(?: ?)out$/) do
  step %{I click the "Log out" link}
end
  