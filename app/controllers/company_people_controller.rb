class CompanyPeopleController < ApplicationController

  def show
    @company_person = CompanyPerson.find(params[:id])
  end

  def edit
    @company_person = CompanyPerson.find(params[:id])
  end

  def update
  end

  def destroy
  end

  private

  def company_person_params
    params.require(:company_person).permit(:first_name, :last_name, :phone,
                :email, :password, :password_confirmation, company_role_ids: [])
  end

end
