class CompanyPeopleController < ApplicationController
  def new
    @company = company.this_company(current_user)
    @company_person = CompanyPerson.new
  end

  def create
    debugger
    @company_person = CompanyPerson.new
    @company_person.assign_attributes(company_person_params)
    @company.company_people << @company_person
    if @company_person.valid?
      @company_person.save
    else
      @model_errors = @company_person.errors
      render :new
    end
  end

  def show
    @company_person = companyPerson.find(params[:id])
  end

  def edit
    @company_person = companyPerson.find(params[:id])
  end

  def update
    @company_person = CompanyPerson.find(params[:id])
    @company_person.assign_attributes(company_person_params)

    if @company_person.save
    else
      @model_errors = @company_person.errors
      render :edit
    end
  end

  def destroy
  end

  private

  def company_person_params
    params.require(:company_person).permit(:first_name, :last_name, :phone, :email, :password, :password_confirmation, :company_id,
                          company_role_ids: [])
  end
end
