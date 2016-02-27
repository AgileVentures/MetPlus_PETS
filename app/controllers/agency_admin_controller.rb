class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.this_agency(current_user)
    @agency_admins = Agency.agency_admins(@agency)
    @branches      = @agency.branches.page(params[:branches_page]).per_page(10)
    @agency_people = @agency.agency_people.page(params[:people_page]).per_page(10)
    @companies     = @agency.companies.page(params[:companies_page]).per_page(10)

    if request.xhr?
      case params[:data_type]
      when 'branches'
        render :partial => 'branches/branches'
      when 'people'
        render :partial => 'agency_people/agency_people'
      when 'companies'
        render :partial => 'companies/companies'
      end
    end
  end
end
