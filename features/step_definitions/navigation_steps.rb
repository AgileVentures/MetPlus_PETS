When(/^I go to the (\w+) page$/) do |page|
  case page
    when 'registration'
      visit user_registration_path
    when 'homepage'
      visit root_path
  end
end

Given(/I am on the (\w+)$/) do |page|
  step "I go to the #{page} page"
end