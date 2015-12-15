class CompanyPeopleController < ApplicationController
<<<<<<< HEAD

  def new
=======
  def new
    # THIS CODE IS NOT READY FOR TESTING
>>>>>>> form work
    @company = company.this_company(current_user)
    @company_person = CompanyPerson.new
  end

<<<<<<< HEAD
=======
  def create
    # THIS CODE IS NOT READY FOR TESTING
    @company = Company.find(params[:company_id])
    @company_person = CompanyPerson.new
    @company_person.assign_attributes(company_person_params)
    @company.company_people << @company_person
    if @company_person.valid?
      @company_person.save
      # need to resolve flash notice in Company and render confirmation
      # flash[:notice] = "Person was successfully created."
    else
      @model_errors = @company_person.errors
      render :new
    end
  end

>>>>>>> form work
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
<<<<<<< HEAD
=======
      #whatif company saves but companyPerson doesn't?
>>>>>>> form work
    else
      @model_errors = @company_person.errors
      render :edit
    end
  end

  def destroy
  end

  private

  def company_person_params
<<<<<<< HEAD
    params.require(:company_person).permit(:first_name, :last_name, :phone, :email, :password, :password_confirmation, :company_id,
                          company_role_ids: [])
=======
    params.require(:company_person).permit(:first_name, :last_name, :phone, :email
                          company_role_ids:)
>>>>>>> form work
  end

end
