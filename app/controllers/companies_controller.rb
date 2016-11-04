class CompaniesController < ApplicationController

  include CompanyPeopleViewer
  before_action :lookup_company

  before_action :user_logged!

  def show
    @company_admins = Company.company_admins(@company)
    @people_type    = 'company-all'
    @admin_aa, @admin_ca = determine_if_admin(pets_user)
    self.action_description= "show the company"
    authorize @company
  end

  def destroy
    @admin_aa = determine_if_admin(pets_user)
    self.action_description= "destroy the company"
    authorize @company
    @company.destroy
    flash[:notice] = "Company '#{@company.name}' deleted."
    redirect_to root_path
  end

  def edit
    self.action_description= "edit the company"
    authorize @company
  end

  def update
    @company.assign_attributes(company_params)
    self.action_description= "update the company"
    authorize @company
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

  def list_people
    raise 'Unsupported request' if not request.xhr?

    @people_type = params[:people_type] || 'my-company-all'

    @people = []
    @people = display_company_people @people_type, @company

    render :partial => 'company_people/list_people',
                       locals: {people: @people,
                                people_type: @people_type,
                                company: @company}
  end

  private

  def lookup_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
    :website, :ein, :description, :job_email,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode, :state, :_destroy])
  end
end
