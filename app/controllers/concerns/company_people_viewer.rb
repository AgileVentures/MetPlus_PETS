module CompanyPeopleViewer
  extend ActiveSupport::Concern

  def display_company_people(company)
    CompanyPerson.joins(:user).all_company_people(company)
  end

  FIELDS_IN_PEOPLE_TYPE = {
    'my-company-all': %i[full_name email phone roles status],
    'company-all': %i[full_name email phone roles status]
  }.freeze

  def company_people_fields(people_type)
    FIELDS_IN_PEOPLE_TYPE[people_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included(mod)
    return unless mod < ActionController::Base

    mod.helper_method :company_people_fields
  end
end
