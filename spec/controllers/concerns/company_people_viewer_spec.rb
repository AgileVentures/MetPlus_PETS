require 'rails_helper'

class TestConcernCompanyPeopleClass < ApplicationController
  include CompanyPeopleViewer
end

RSpec.describe TestConcernCompanyPeopleClass do
  let(:company)       { FactoryBot.create(:company) }
  let(:cmpy_person1)  { FactoryBot.create(:company_contact, company: company) }
  let(:cmpy_person2)  { FactoryBot.create(:company_contact, company: company) }
  let(:cmpy_person3)  { FactoryBot.create(:company_contact, company: company) }
  let(:people_fields) { TestConcernCompanyPeopleClass::FIELDS_IN_PEOPLE_TYPE }

  describe '#display_company_people' do
    it 'returns all company people for a specified company' do
      expect(subject.display_company_people(company))
        .to match_array [cmpy_person1, cmpy_person2, cmpy_person3]
    end

    it 'returns all fields for company people' do
      expect(subject.company_people_fields('company-all'))
        .to match_array people_fields['company-all'.to_sym]
    end

    it 'returns all fields for my company people' do
      expect(subject.company_people_fields('my-company-all'))
        .to match_array people_fields['my-company-all'.to_sym]
    end
  end
end
