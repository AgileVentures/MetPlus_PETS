class CompaniesController < ApplicationController

  include CompanyPeopleViewer

  def show
    @company        = Company.find(params[:id])
    @company_admins = Company.company_admins(@company)
    @people_type    = 'company-all'
    @admin_aa, @admin_ca = determine_if_admin(pets_user)
  end

  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Company '#{company.name}' deleted."
    redirect_to root_path
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    @company.assign_attributes(company_params)
    if @company.valid?
      @company.save
      flash[:notice] = "company was successfully updated."
      admin_aa, admin_ca = determine_if_admin(pets_user)
      if admin_ca
        redirect_to home_company_person_path(pets_user)
      else
        redirect_to company_path(@company)
      end
    else
      render :edit
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
    :website, :ein, :description, :job_email,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode, :state, :_destroy])
  end
end
