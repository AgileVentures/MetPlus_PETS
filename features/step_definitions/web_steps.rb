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

Then(/^(?:I|they) should( not)? see button "([^"]*)"$/) do |not_see, button|
  unless not_see
    expect(page).to have_button button
  else
    expect(page).to_not have_button button
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
  regex = /#{Regexp.quote("#{first}")}.+#{Regexp.quote("#{toSearch}")}.+#{Regexp.quote("#{last}")}/
  search_text regex
end

Then(/^I should( not)? see "([^"]*)" before "([^"]*)"$/) do |not_see, toSearch, last|
  regex = /#{Regexp.quote("#{toSearch}")}.+#{Regexp.quote("#{last}")}/
  if not_see
    expect(page.text).not_to match regex
  else
    expect(page.text).to match regex
  end
end

Then(/^(?:I|they) should( not)? see "([^"]*)" after "([^"]*)"$/) do |not_see, toSearch, first|
  regex = /#{Regexp.quote("#{first}")}.+#{Regexp.quote("#{toSearch}")}/
  if not_see
    expect(page.text).not_to match regex
  else
    expect(page.text).to match regex
  end
end

Then(/^I wait(?: for)? (\d+) second(?:s)?$/) do |seconds|
  sleep seconds.to_i.seconds
end

When(/^(?:I|they) fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in field, with: value
end

When(/^(?:I|they) click the( \w*)? "([^"]*)" link$/) do |ordinal, link|
  # use 'ordinal' when selecting among select links all of which
  # have the same selector (e.g., same label)

  if not ordinal
    if Capybara.current_driver == :poltergeist
      find_link(link).trigger('click')
    else
      click_link link
    end
  else
    case ordinal
    when ' first'
      index = 0
    when ' second'
      index = 1
    when ' third'
      index = 2
    else
      raise 'do not understand ordinal value'
    end
    if Capybara.current_driver == :poltergeist
      all(:link, link)[index].trigger('click')
    else
      all(:link, link)[index].click
    end
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

When(/^(?:I|they) click(?: the)?( \w*)? "([^"]*)" button$/) do |ordinal, button|
  if not ordinal
    click_button button
  else
    case ordinal
    when ' first'
      index = 0
    when ' second'
      index = 1
    when ' third'
      index = 2
    else
      raise 'do not understand ordinal value'
    end
    if Capybara.current_driver == :poltergeist
      all(:button, text: button)[index].trigger('click')
    else
      all(:button, text: button)[index].click
    end
  end
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

When(/^(?:I|they) select "([^"]*)" in( \w*)? select list "([^"]*)"$/) do |item, ordinal, lst|
  # use 'ordinal' when selecting among select lists all of which
  # have the same selector (e.g., same label)
  case ordinal
  when nil
    find(:select, lst).find(:option, item).select_option
  when ' first'
    all(:select, lst)[0].find(:option, item).select_option
  when ' second'
    all(:select, lst)[1].find(:option, item).select_option
  when ' third'
    all(:select, lst)[2].find(:option, item).select_option
  else
    raise 'do not understand ordinal value'
  end
end

And(/^(?:I|they) check( \w*)? "([^"]*)"$/) do |ordinal, item|
  # use 'ordinal' when selecting among select checkboxes all of which
  # have the same selector (e.g., same label)
  case ordinal
  when nil
    check(item)
  when ' first'
    all(:checkbox, item)[0].set(true)
  when ' second'
    all(:checkbox, item)[1].set(true)
  when ' third'
    all(:checkbox, item)[2].set(true)
  else
    raise 'do not understand ordinal value'
  end
end

And(/^the selection "([^"]*)" should be disabled$/) do |item|
  expect(has_field?(item, disabled: true)).to be true
end

When /^I reload the page$/ do
  visit current_path
end

When /^I am in (.*) browser$/ do |name|
  Capybara.session_name = name
end

Then(/^I select2 "([^"]*)" from "([^"]*)"$/) do |value, select_name|

  find("#select2-#{select_name}-container").click
  find(".select2-search__field").set(value)
  within ".select2-results" do
    find("li", text: value).click
  end
end

When /^I choose resume file "([^"]*)"$/ do |filename|
  attach_file('Resume', "#{Rails.root}/spec/fixtures/files/#{filename}")
end

When /^The field '([^']+)' should have the value '([^']+)'$/ do |field, value|
  expect(page).to have_field(field, with: value)
end

