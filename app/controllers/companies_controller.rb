class CompaniesController < ApplicationController

  include CompanyPeopleViewer

  def show
    @company        = Company.find(params[:id])
    @company_admins = Company.company_admins(@company)
    @people_type    = 'company-all'
    @admin_type     = params[:admin_type]
  end

  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Company '#{company.name}' deleted."
    redirect_to root_path
  end

  def edit
    @company = Company.find(params[:id])
    @admin_type = params[:admin_type]
  end

  def update
    @company = Company.find(params[:id])
    @company.assign_attributes(company_params)
    if @company.valid?
      @company.save
      flash[:notice] = "company was successfully updated."
      case params[:admin_type]
      when 'CA'
        redirect_to home_company_person_path(pets_user)
      when 'AA'
        redirect_to company_path(@company, admin_type: 'AA')
      end
    else
      @admin_type = params[:admin_type]
      render :edit
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
    :website, :ein, :description,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode, :state, :_destroy])
  end
end
