require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CompanyPeopleHelper. For example:
#
# describe CompanyPeopleHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe CompanyPeopleHelper, type: :helper do
  it 'returns true when company admin is the sole admin' do
    company_admin = create(:company_admin)
    expect(disable_company_admin?(company_admin, 'Company Admin')).to be true
  end

  it 'returns false when company admin edits another company admin' do
    company = create(:company)
    create(:company_admin, company: company)
    company_admin2 = create(:company_admin, company: company)
    expect(disable_company_admin?(company_admin2, 'Company Contact')).to be false
  end

  it 'returns false when a company admin edits contact person who is not admin' do
    company_contact = create(:company_contact)
    expect(disable_company_admin?(company_contact, 'Company Contact')).to be false
  end
end
