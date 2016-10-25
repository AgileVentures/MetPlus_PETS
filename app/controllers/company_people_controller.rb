class CompanyPeopleController < ApplicationController
  include Tasks
  include UserParameters

  include CompanyPeopleViewer

  def show
    @company_person = CompanyPerson.find(params[:id])
  end

  def edit
    @company_person = CompanyPerson.find(params[:id])
  end

  def edit_profile
    @company_person = CompanyPerson.find(params[:id])
    @company_addresses = Company.find(@company_person.company_id).addresses
  end

  def update_profile
    @company_person = CompanyPerson.find(params[:id])
    @company_addresses = Company.find(@company_person.company_id).addresses

    person_params = handle_user_form_parameters company_person_params
    if @company_person.update_attributes(person_params)
      sign_in :user, @company_person.user, bypass: true
      flash[:notice] = "Your profile was updated successfully."
      redirect_to @company_person
    else
      render :edit_profile
    end
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
    redirect_to home_company_person_path(person.id)
  end

  def home
    @task_type      = 'mine-open'
    @company_all    = 'company-all'
    @company_new    = 'company-new'
    @company_closed = 'company-closed'
    
    @job_type    = 'my-company-all'
    @people_type = 'my-company-all'
    @company     = pets_user.company
    @company_admins = Company.company_admins(@company)
    @company_person = pets_user
    @admin_aa, @admin_ca = determine_if_admin(pets_user)
  end

  private

  def company_person_params
    params.require(:company_person).permit(:title, :first_name, :last_name, :phone,
                :email, :password, :password_confirmation, :address_id, company_role_ids: [])
  end
end
