class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.this_agency(current_user)
    @agency_admins = Agency.agency_admins(@agency)
  end
end
