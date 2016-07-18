# Usage:
# 	I do not have an address
# 	I have an address with "full address"
And /^I(?: do not)? have an address(?: with "([^"]*)")?/ do |address|
	if address
		page.has_select?('Address', :selected => "#{address}")
	else
		expect(page.find('#company_person_address_id')).not_to have_css("selected")
	end
end

# Usage:
# 	I should see selections of "my company" addresses
# 	I should not see selections of "other company" addresses
And /^I should( not)? see selections of "([^"]*)" addresses$/ do |negate, company|
	Company.find_by(name: company).addresses.each do |address|
		if negate
			expect(page).not_to have_content("#{address.full_address}")
		else
			expect(page).to have_content("#{address.full_address}")
		end
	end
end


