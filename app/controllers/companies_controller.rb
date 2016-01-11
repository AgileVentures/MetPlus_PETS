<<<<<<< HEAD
class CompaniesController < ApplicationController
=======

class CompaniesController < ApplicationController

  def show
    @company = Company.find(params[:id])
  end

  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Company '#{company.name}' deleted."
    redirect_to root_path
  end

  def update
  end
 
  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
    :website, :ein, :description,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode])
  end

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
end
