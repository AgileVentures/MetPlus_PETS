class CompaniesController < ApplicationController
  include CompanyPeopleViewer

  helper_method :company_people_fields

  def show
    @company = Company.find(params[:id])
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
      redirect_to company_path(@company)
    else
      @model_errors = @company.errors
      render :edit
    end
  end

  def list_people
    raise 'Unsupported request' if not request.xhr?

    @company = Company.find(params[:id])

    @people_type = params[:people_type] || 'my-company-all'

    @people = []
    @people = display_company_people @people_type

    render :partial => 'company_people/list_people',
                       locals: {people: @people,
                                people_type: @people_type,
                                company: @company}
	end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
    :website, :ein, :description,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode, :state])
  end
end
