class CompaniesController < ApplicationController

  def show
    @company = Company.find(params[:id])
  end

<<<<<<< HEAD
  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Company '#{company.name}' deleted."
    redirect_to root_path
  end

  def update
=======
  def show
    @company = Company.find(company_params[:id])
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      flash.notice = "Success!"
      redirect_to root_path
    else
      render 'new'
      flash.notice = @company.errors
    end
>>>>>>> still more routes
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
    :website, :ein, :description,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode])
  end
end
