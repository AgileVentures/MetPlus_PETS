class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.this_agency(current_user)
    @agency_admins = Agency.agency_admins(@agency)
    @branches      = @agency.branches.page(params[:branches_page]).per_page(10)
    @agency_people = @agency.agency_people.page(params[:people_page]).per_page(10)
    @companies     = @agency.companies.page(params[:companies_page]).per_page(10)

    render :partial => 'branches/branches' if
                      request.xhr? && params[:data_type] == 'branches'

    render :partial => 'agency_people/agency_people' if
                      request.xhr? && params[:data_type] == 'people'

    render :partial => 'companies/companies' if
                      request.xhr? && params[:data_type] == 'companies'
  end
end
