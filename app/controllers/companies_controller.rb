class CompaniesController < ApplicationController

  def new
    @company = Company.new
  end

  def show
    @company = Company.find(company_params[:id])
  end

  def create
    @company = Company.new(company_params)
    @company.agencies << Agency.first
    if @company.save
      flash.notice = "Success!"
      render 'confirmation'
    else
      render 'new'
      @model_errors = @company.errors
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
   	:website, :ein, :description)

  end

end
