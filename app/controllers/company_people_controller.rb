class CompanyPeopleController < ApplicationController
  before_action :user_logged!
  before_action :load_and_authorize_company_person

  include Tasks
  include UserParameters

  include CompanyPeopleViewer

  def show; end

  def edit; end

  def edit_profile
    @company_addresses = Company.find(@company_person.company_id).addresses
  end

  def update_profile
    @company_addresses = Company.find(@company_person.company_id).addresses

    person_params = handle_user_form_parameters company_person_params
    if @company_person.update_attributes(person_params)
      bypass_sign_in(@company_person.user, scope: :user)
      if @company_person.user.unconfirmed_email?
        flash[:warning] = 'Please check your inbox to update your email address.'
      else
        flash[:notice] = 'Your profile was updated successfully.'
      end
      is_company_admin = @company_person.company_admin? @company_person.company

      redirect_to is_company_admin ?
        @company_person : home_company_person_path(@company_person)
    else
      render :edit_profile
    end
  end

  def update
    cp_params = company_person_params
    cp_params[:company_role_ids] = [] if cp_params[:company_role_ids].nil?
    if @company_person.update_attributes(cp_params)
      flash[:notice] = 'Company person was successfully updated.'
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
    @company_person.destroy
    flash[:notice] =
      "Person '#{@company_person.full_name(last_name_first: false)}' deleted."

    if pets_user.is_a? AgencyPerson
      redirect_to home_agency_person_path(pets_user.id)
    else
      redirect_to home_company_person_path(pets_user.id)
    end
  end

  def home
    if request.xhr?

      if params[:data_type] == 'skills'

        @skills = pets_user.company.skills.order(:name)
                           .page(params[:skills_page]).per_page(10)

        render partial: 'shared/job_skills', object: @skills,
               locals: { data_type: 'skills',
                         partial_id: 'skills_table',
                         show_property_path: :skill_path,
                         delete_property_path: :skill_path }

      elsif params[:data_type] == 'licenses'

        @licenses = License.order(:abbr)
                           .page(params[:licenses_page]).per_page(10)

        render partial: 'shared/licenses', object: @licenses,
               locals: { data_type: 'licenses',
                         partial_id: 'licenses_table',
                         show_property_path: :license_path,
                         delete_property_path: :license_path }
      else
        raise "Do not recognize data type: #{params[:data_type]}"
      end
    else
      @task_type      = 'mine-open'
      @company_all    = 'company-all'
      @company_new    = 'company-new'
      @company_closed = 'company-closed'

      @job_type    = 'my-company-all'
      @people_type = 'my-company-all'
      @company     = pets_user.company
      @company_admins = Company.company_admins(@company)
      @admin_aa, @admin_ca = determine_if_admin(pets_user)

      @skills = @company.skills.order(:name)
                        .page(params[:skills_page]).per_page(10)

      @licenses = License.order(:abbr)
                         .page(params[:licenses_page]).per_page(10)
    end
  end

  def my_profile; end

  private

  def load_and_authorize_company_person
    @company_person = CompanyPerson.find(params[:id])
    authorize @company_person
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path,
                alert: "The company person you're looking for doesn't exist"
  end

  def company_person_params
    params.require(:company_person).permit(:title, :first_name, :last_name, :phone,
                                           :email, :password, :password_confirmation,
                                           :address_id, company_role_ids: [])
  end
end
