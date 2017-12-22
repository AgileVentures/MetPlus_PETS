
And(/^I do not have an address$/) do
  expect(page.find('#company_person_address_id')).not_to have_css('selected')
end

# Usage:
# 	I should see selections of "my company" addresses
# 	I should not see selections of "other company" addresses
And(/^I should( not)? see selections of "([^"]*)" addresses$/) do |negate, company|
  Company.find_by(name: company).addresses.each do |address|
    if negate
      expect(page).not_to have_content(address.full_address.to_s)
    else
      expect(page).to have_content(address.full_address.to_s)
    end
  end
end
