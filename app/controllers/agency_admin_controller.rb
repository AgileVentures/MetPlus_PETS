class AgencyAdminController < ApplicationController
  def home
    # Cancancan before_filter here .....

    @agency = Agency.this_agency(current_user)
    @agency_admins = Agency.agency_admins(@agency)
    @branches = @agency.branches.page(params[:page]).per_page(20)
    # @people   = @agency.agency_people.page(params[:page]).per_page(20)
    @people   = @agency.agency_people

    # respond_to do |format|
    #   format.html
    #   ajax_respond format, section_id: 'branches'
    # end
  end
end
