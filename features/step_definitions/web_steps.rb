Then(/^I should see "([^"]*)"$/) do |text|
  page.has_content? text
end

And(/^I press "([^"]*)"$/) do |name|
  click_on name
end

And(/^I fill in the fields$/) do |table|
  # table is a table.hashes.keys # => [:Username, :admin]
  table.each do |field, value|
    fill_in field, :with => value
  end
end