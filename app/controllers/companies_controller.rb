class CompaniesController < ApplicationController

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      flash.notice = "Success!"
      redirect_to root_path
    else
      render 'new'
      flash.notice = "Oopsie!"
    end
  end

  private

  def company_params
   	params.require(:company).permit(:name, :email, :phone,
   	:website, :ein, :description)
 	end

end
