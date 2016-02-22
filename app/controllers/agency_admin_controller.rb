class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.this_agency(current_user)
    @agency_admins = Agency.agency_admins(@agency)
    @branches = @agency.branches.page(params[:branches_page]).per_page(5)
    @people   = @agency.agency_people.page(params[:people_page]).per_page(2)
  end
end
