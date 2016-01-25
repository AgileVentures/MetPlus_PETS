class CompanyPeopleController < ApplicationController

  def new
    @company = company.this_company(current_user)
    @company_person = CompanyPerson.new
  end

  def create
  end

  def show
    @company_person = CompanyPerson.find(params[:id])
  end

  def edit
    @company_person = CompanyPerson.find(params[:id])
  end

  def update
    @company_person = CompanyPerson.find(params[:id])
    person_params = company_person_params
    if person_params['password'].to_s.length == 0 
       person_params.delete('password')
       person_params.delete('password_confirmation')
    end
    if @company_person.update_attributes(person_params)
      sign_in :user, @company_person.user, bypass: true
      flash[:notice] = "Your profile was updated successfully."
      redirect_to root_path
    else
      @model_errors = @company_person.errors
      render :edit
    end
  end

  def destroy
  end

  private

  def company_person_params
    params.require(:company_person).permit(:title, :first_name, :last_name, :phone,
                :email, :password, :password_confirmation, company_role_ids: [])
  end

end
