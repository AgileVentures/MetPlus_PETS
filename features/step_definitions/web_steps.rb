def wait_until
  require "timeout"
  #Timeout.timeout(Capybara.default_wait_time) do
  Timeout.timeout(10) do
    sleep(0.1) until value = yield
    value
  end
end
def search_text text
  wait_until do
    if text.is_a? Regexp
      expect(page).to have_content text
    else
      expect(page).to have_content text
    end
  end
end
Then(/^(?:I|they) should( not)? see "([^"]*)"$/) do |not_see, string|
  unless not_see
    expect(page.body).to have_text string
  else
    expect(page.body).to_not have_text string
  end
end

Then(/^"([^"]*)" should( not)? be visible$/) do |string, not_see|
  unless not_see
    expect(has_text?(:visible, string)).to be true
  else
    expect(has_text?(:visible, string)).to be false
  end
end

And(/^I press "([^"]*)"$/) do |name|
  click_on name
end

Then(/^I should see "([^"]*)" between "([^"]*)" and "([^"]*)"$/) do |toSearch, first, last|
  regex = /#{first}.+#{toSearch}.+#{last}/
  search_text regex
end

Then(/^I wait(?: for)? (\d+) second(?:s)?$/) do |seconds|
  sleep seconds.to_i.seconds
end

When(/^(?:I|they) fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in field, with: value
end

When(/^(?:I|they) click the "([^"]*)" link$/) do |link|
  if Capybara.current_driver == :poltergeist
    find_link(link).trigger('click')
  else
    click_link link
  end
  # see discussion here:
  # https://github.com/teampoltergeist/poltergeist/issues/520
end

When(/^(?:I|they) click the link with url "([^"]*)"$/) do |url|
  if Capybara.current_driver == :poltergeist
    find_link('', {href: url}).trigger('click')
  else
    click_link('', {href: url})
  end
end

When(/^(?:I|they) click(?: the)? "([^"]*)" button$/) do |button|
  click_button button
end

When(/^(?:I|they) fill in the fields:$/) do |table|
  # table is a table.hashes.keys # => [:First name, :John]
  table.raw.each do |field, value|
    fill_in field, :with => value
  end
end

And(/^show me the page$/) do
  save_and_open_page
end

When(/^(?:I|they) click and accept the "([^"]*)" button$/) do |button_text|
  # accept_confirm(wait: 8) do
  #   click_button button_text
  # end
  page.driver.accept_modal(:confirm, wait: 8) do
    click_button button_text
  end
end

When(/^(?:I|they) select "([^"]*)" in select list "([^"]*)"$/) do |item, list|
  find(:select, list).find(:option, item).select_option
end

And(/^(?:I|they) check "([^"]*)"$/) do |item|
  check(item)
end

And(/^the selection "([^"]*)" should be disabled$/) do |item|
  expect(has_field?(item, disabled: true)).to be true
end

When /^I reload the page$/ do
  visit current_path
end
