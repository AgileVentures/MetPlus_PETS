Then(/^I should see "(.*?)" in the title$/) do |title|
  expect(page).to have_title(title)
end
