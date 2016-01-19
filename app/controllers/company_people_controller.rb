class CompanyPeopleController < ApplicationController

  def show
    @company_person = CompanyPerson.find(params[:id])
  end

  def edit
    @company_person = CompanyPerson.find(params[:id])
  end

  def update
    @company_person = CompanyPerson.find(params[:id])

    if @company_person.update_attributes(company_person_params)
      flash[:notice] = "Company person was successfully updated."
      redirect_to company_person_path(@company_person)
    else
      unless @company_person.errors[:company_admin].empty?

        # If the :company_admin error key was set by the model this means that
        # the company person being edited is the sole company admin (CA), and that
        # role was unchecked in the edit view. Removing the sole CA is not allowed.
        # In this case, reset the CA role.

        @company_person.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CA])
      end
      @model_errors = @company_person.errors
      render :edit
    end
  end

  def destroy
    person = CompanyPerson.find(params[:id])
    if person.user != current_user
      person.destroy
      flash[:notice] = "Person '#{person.full_name(last_name_first: false)}' deleted."
    else
      flash[:alert] = "You cannot delete yourself."
    end
    redirect_to company_path(person.company)
  end

  private

  def company_person_params
    params.require(:company_person).permit(company_role_ids: [])
  end
end
