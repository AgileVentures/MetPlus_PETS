module CompanyPeopleViewer
  extend ActiveSupport::Concern

  def display_company_people(people_type, company = nil, per_page = 10,
                             page_name = nil, order_by = nil)

    page_name ||= params[:people_page]

    case people_type
    when 'my-company-all'
      return CompanyPerson.joins(:user).order(order_by).
              paginate(page: page_name, per_page: per_page).
              all_company_people(pets_user.company)
    when 'company-all'
      return CompanyPerson.joins(:user).order(order_by).
              paginate(page: page_name, per_page: per_page).
              all_company_people(company)
    end
  end

  FIELDS_IN_PEOPLE_TYPE = {
      'my-company-all': [:full_name, :email, :phone, :roles, :status],
      'company-all':    [:full_name, :email, :phone, :roles, :status]
  }

  def company_people_fields people_type
    FIELDS_IN_PEOPLE_TYPE[people_type.to_sym] || []
  end

  # make helper methods visible to views
  def self.included m
    return unless m < ActionController::Base
    m.helper_method :company_people_fields
  end
end
