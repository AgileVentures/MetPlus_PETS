class AgencyController < ApplicationController
  # This controller manages activities for agency people who
  # do not have admin rights.

  # 'home' is the agency 'landing page', where admin people
  # are sent upon login
  def home
    @agency = Agency.find(params[:id])
  end
end
