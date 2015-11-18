class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....
    @agency = Agency.this_agency(current_user)
    @agency_manager = Agency.agency_manager(current_user)
  end
end
