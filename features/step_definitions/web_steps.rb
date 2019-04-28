def wait_until
  require 'timeout'
  # Timeout.timeout(Capybara.default_wait_time) do
  Timeout.timeout(10) do
    sleep(0.1) until value == yield
    value
  end
end

def search_text(text)
  wait_until do
    expect(page).to have_content(text, normalize_ws: true)
  end
end

Then(/^(?:I|they) should( not)? see "([^"]*)"$/) do |not_see, string|
  if not_see
    expect(page).to_not have_text(string, normalize_ws: true)
  else
    expect(page).to have_text(string, normalize_ws: true)
  end
end

Then(/^I should not see the "(.*?)" link$/) do |link|
  expect(page.body).to_not have_link link
end

Then(/^(?:I|they) should( not)? see button "([^"]*)"$/) do |not_see, button|
  if not_see
    expect(page).to_not have_button button
  else
    expect(page).to have_button button
  end
end

Then(/^"([^"]*)" should( not)? be visible$/) do |string, not_see|
  if not_see
    expect(has_text?(:visible, string)).to be false
  else
    expect(has_text?(:visible, string)).to be true
  end
end

And(/^I press "([^"]*)"$/) do |name|
  click_on name
end

Then(/^I\sshould\ssee\s"([^"]*)"\s
  between\s"([^"]*)"\sand\s"([^"]*)"$/x) do |to_search, first, last|
  regex = /#{Regexp.quote(first.to_s)}.+#{Regexp.quote(to_search.to_s)}.
  +#{Regexp.quote(last.to_s)}/
  search_text regex
end

And(/^I\sshould\ssee\s"([^"]*)"\sin\sthe\ssame\stable\srow\sas\s
  "([^"]*)"$/x) do |to_search, anchor_text|
  expect(find('tr', text: anchor_text)).to have_content(to_search)
end

Then(/^I\sshould(\snot)?\ssee\s"([^"]*)"\s
  before\s"([^"]*)"$/x) do |not_see, to_search, last|
  expect(page.body).to have_text to_search
  regex = /#{Regexp.quote(to_search.to_s)}.+#{Regexp.quote(last.to_s)}/
  if not_see
    expect(page.text).not_to have_text(regex, normalize_ws: true)
  else
    expect(page.text).to have_text(regex, normalize_ws: true)
  end
end

Then(/^(?:I|they)\sshould(\snot)?\ssee\s"([^"]*)"\s
  after\s"([^"]*)"$/x) do |not_see, to_search, first|
  expect(page.body).to have_text to_search
  regex = /#{Regexp.quote(first.to_s)}.+#{Regexp.quote(to_search.to_s)}/
  if not_see
    expect(page.text).not_to have_text(regex, normalize_ws: true)
  else
    expect(page.text).to have_text(regex, normalize_ws: true)
  end
end

Then(/^page should have "([^"]*)" before "([^"]*)"$/) do |to_search, last|
  expect(page.body).to have_text to_search
  regex = /#{Regexp.quote(to_search.to_s)}.+#{Regexp.quote(last.to_s)}/m
  expect(page.text).to have_text(regex, normalize_ws: true)
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
  if !ordinal
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

When(/^(?:I|they) click the "([^"]*)" react link$/) do |link|
  if Capybara.current_driver == :poltergeist
    find_link(link).trigger('click')
  else
    link_obj = find(link)
    expect(link_obj.tag_name).to eq('a')
    link_obj.click
  end
end

When(/^(?:I|they) click the "([^"]*)" link and switch to the new window$/) do |link|
  new_window = window_opened_by do
    click_link link
  end
  switch_to_window new_window
end

When(/^(?:I|they) click the "([^"]+)" link with url "([^"]*)"$/) do |text, url|
  if Capybara.current_driver == :poltergeist
    find_link(text, href: url).trigger('click')
  else
    click_link(text, href: url)
  end
end

When(/^(?:I|they) click(?: the)?( \w*)? "([^"]*)" button$/) do |ordinal, button|
  if !ordinal
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

When(/^(?:I|they) choose(?: the)? "([^"]*)" radio button$/) do |button|
  choose button
end

When(/^(?:I|they) fill in the fields:$/) do |table|
  # table is a table.hashes.keys # => [:First name, :John]
  table.raw.each do |field, value|
    fill_in field, with: value
  end
end

And(/^show me the page$/) do
  save_and_open_page
end

When(/^(?:I|they) click and accept the "([^"]*)" button$/) do |button_text|
  page.driver.accept_modal(:confirm, wait: 8) do
    click_button button_text
  end
end

When(/^(?:I|they)\sselect\s"([^"]*)"\sin(\s\w*)?\sselect\slist\s
  "([^"]*)"$/x) do |item, ordinal, lst|
  # use 'ordinal' when selecting among select lists all of which
  # have the same selector (e.g., same label)
  case ordinal
  when nil
    find(:select, lst, minimum: 1).find(:option, item).select_option
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

Then(/^"([^"]*)"\sshould(\snot)?\sbe\san\soption\sfor\sselect\slist\s
  "([^"]*)"$/x) do |option, negate, lst|
  if negate
    expect(page).not_to have_selector(:xpath,
                                      "//label[. = '#{lst}']" \
                                      '/following-sibling::div' \
                                      "/select/option[. = '#{option}']")
  else
    expect(page).to have_selector(:xpath,
                                  "//label[. = '#{lst}']" \
                                  '/following-sibling::div' \
                                  "/select/option[. = '#{option}']")
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

And(/^(?:I|they) uncheck( \w*)? "([^"]*)"$/) do |ordinal, item|
  # use 'ordinal' when selecting among select checkboxes all of which
  # have the same selector (e.g., same label)
  case ordinal
  when nil
    uncheck(item)
  when ' first'
    all(:checkbox, item)[0].set(false)
  when ' second'
    all(:checkbox, item)[1].set(false)
  when ' third'
    all(:checkbox, item)[2].set(false)
  else
    raise 'do not understand ordinal value'
  end
end

And(/^the selection "([^"]*)" should be disabled$/) do |item|
  expect(has_field?(item, disabled: true)).to be true
end

When(/^I reload the page$/) do
  visit current_path
end

When(/^I am in (.*) browser$/) do |name|
  Capybara.session_name = name
end

Then(/^I( cannot)? select2 "([^"]*)" from "([^"]*)"$/) do |cannot, value, select_name|
  find("#select2-#{select_name}-container").click
  find('.select2-search__field').set(value)
  if cannot
    within('.select2-results') do
      expect(page.find('li')).to have_text('No results found')
    end
  else
    within('.select2-results') { find('li', text: value).click }
  end
end

When(/^I choose resume file "([^"]*)"$/) do |filename|
  attach_file('Resume', "#{Rails.root}/spec/fixtures/files/#{filename}")
end

When(/^The field '([^']+)' should have the value '([^']+)'$/) do |field, value|
  expect(page).to have_field(field, with: value)
end

Then(/^I should see "([^"]+)" in the email field$/) do |value|
  step %(The field 'Email' should have the value '#{value}')
end

Then(/^I save the page as "([^"]+)"$/) do |screen|
  page.save_screenshot(screen.to_s, full: true)
end

When(/^(?:I|they) select radio button "([^"]*)"$/) do |label_text|
  find(:xpath, "//label[contains(.,'#{label_text}')]/input[@type='radio']").click
end

When(/^I press "(.*?)" within "(.*?)"$/) do |text, field|
  within("##{field}") do
    step %(I press "#{text}")
  end
end

Then(/^I sould see a text field "(.*?)" with the value set to (\d+)$/) do |name, value|
  find_field(name, with: value)
end

Then(/^I should see a link "([^"]*)" pointing to "([^"]*)"$/) do |link_name, link|
  find_link(link_name)
  expect(page).to have_selector(:css, "a[href$='#{link}']")
end

Then(/^I should not see a link "([^"]*)" pointing to "([^"]*)"$/) do |link_name, link|
  find_link(link_name)
  expect(find_link(link_name)).to have_no_selector(:css, "a[href$='#{link}']")
end
