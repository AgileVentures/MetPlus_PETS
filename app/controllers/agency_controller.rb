class AgencyController < ApplicationController
  def home
    @agency = Agency.find(params[:id])
  end
end
