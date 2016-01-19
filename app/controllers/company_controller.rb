class CompanyController < ApplicationController
  # This controller manages activities for compant people who
  # do not have admin rights.

  # 'home' is the company 'landing page', where company people
  # are sent upon login
  def home
    @company = Company.find(params[:id])
  end
end
