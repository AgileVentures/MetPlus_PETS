# Company controller
class CompaniesController < ApplicationController
  include CompanyPeopleViewer
  include PaginationUtility

  before_action :lookup_company

  before_action :user_logged!

  def show
    self.action_description = 'show the company'
    authorize @company
    @company_admins = Company.company_admins(@company)
    @people_type    = 'company-all'
    @admin_aa, @admin_ca = determine_if_admin(pets_user)
  end

  def destroy
    self.action_description = 'destroy the company'
    authorize @company
    if @company.jobs.exists?
      redirect_to(@company, alert: 'Company cannot be deleted') && return
    end

    @company.destroy
    flash[:notice] = "Company '#{@company.name}' deleted."
    redirect_to root_path
  end

  def edit
    self.action_description = 'edit the company'
    authorize @company
  end

  def update
    self.action_description = 'update the company'
    authorize @company
    @company.assign_attributes(company_params)
    if @company.valid?
      @company.save
      flash[:notice] = 'company was successfully updated.'
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
    raise 'Unsupported request' unless request.xhr?
    self.action_description = 'view the people'
    authorize @company

    people_type = params[:people_type] || 'my-company-all'

    search_params, items_count, items_per_page = process_pagination_params('cmpy_people')

    people = display_company_people(people_type, @company)

    # Add Ransack params to people query (here, just sorting, no search)
    query = people.ransack(search_params)

    people = query.result.page(params[:page]).per_page(items_per_page)

    render partial: 'company_people/list_people',
           locals: { people: people,
                     people_type: people_type,
                     company: @company,
                     items_count: items_count,
                     query: query }
  end

  private

  def lookup_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
                                    :website, :ein, :description,
                                    :job_email,
                                    company_people_attributes:
                                  [:id, :first_name, :last_name, :phone, :email,
                                   :password, :password_confirmation],
                                    addresses_attributes:
                             [:id, :street, :city, :zipcode, :state, :_destroy])
  end
end
