class CompaniesController < ApplicationController

  def new
    @company = Company.new
    @company.addresses.build
    @company.company_people.build
  end

  def show
    @company = Company.find(company_params[:id])
  end

  def create
    @company = Company.new
    @company.assign_attributes(company_params)
    @company.agencies << Agency.first
    if @company.save
      flash.notice = "Success!"
      render 'confirmation'
    else
      @model_errors = @company.errors
      render 'new'
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
    :website, :ein, :description,
    {company_people_attributes: [:id, :first_name, :last_name, :phone, :email, :password, :password_confirmation]},
    addresses_attributes: [:id, :street, :city, :zipcode])
  end

end
