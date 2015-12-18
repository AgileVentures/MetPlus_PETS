class CompaniesController < ApplicationController

  def new
    @company = Company.new
  end

  def show
    @company = Company.find(company_params[:id])
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      flash.notice = "Success!"
      redirect_to root_path
      # associate with an agency, either MetPlus or agencies.first
    else
      render 'new'
      flash.notice = @company.errors
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
   	:website, :ein, :description)

  end

end
