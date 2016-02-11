class AgencyController < ApplicationController
  # This controller manages activities for agency people
  # (features for agency admins are managed in separate controller).

  # 'home' is the agency 'landing page', where agency people
  # are sent upon login
  def home
    @agency = Agency.find(params[:id])
  end
end
