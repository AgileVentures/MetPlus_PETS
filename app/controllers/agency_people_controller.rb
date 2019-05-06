class AgencyPeopleController < ApplicationController
  include UserParameters
  include JobSeekersViewer

  before_action :user_logged!

  def show
    @agency_person = AgencyPerson.find(params[:id])
    self.action_description = 'show an agency person'
    authorize @agency_person
  end

  def edit
    @agency_person = AgencyPerson.find(params[:id])
    self.action_description = 'edit an agency person'
    authorize @agency_person
  end

  def home
    @agency_person = AgencyPerson.find(params[:id])
    self.action_description = 'go to agency person home page'
    authorize @agency_person

    @agency = @agency_person.agency
    @task_type = 'mine-open'
    @agency_all = 'agency-all'
    @agency_new = 'agency-new'
    @agency_closed = 'agency-closed'
    @people_type_cm = 'jobseeker-cm'
    @people_type_jd = 'jobseeker-jd'
    @people_type_without_jd = 'jobseeker-without-jd'
    @people_type_without_cm = 'jobseeker-without-cm'
    @js_without_jd = JobSeeker.job_seekers_without_job_developer
    @js_without_cm = JobSeeker.job_seekers_without_case_manager
    @your_jobseekers_jd = @agency_person.job_seekers_as_job_developer
    @your_jobseekers_cm = @agency_person.job_seekers_as_case_manager
  end

  def update
    @agency_person = AgencyPerson.find(params[:id])

    self.action_description = 'edit an agency person'
    authorize @agency_person

    model_params = agency_person_params
    jd_job_seeker_ids = model_params.delete(:as_jd_job_seeker_ids)
    cm_job_seeker_ids = model_params.delete(:as_cm_job_seeker_ids)

    @agency_person.assign_attributes(model_params)

    if @agency_person.save
      assign_new_job_seekers = AgencyPeople::AssignNewJobSeekers.new
      begin
        assign_new_job_seekers.call(
          JobSeeker.where(id: jd_job_seeker_ids),
          :JD,
          @agency_person
        )
        assign_new_job_seekers.call(
          JobSeeker.where(id: cm_job_seeker_ids),
          :CM,
          @agency_person
        )

        flash[:notice] = 'Agency person was successfully updated.'
        redirect_to agency_person_path(@agency_person)
      rescue JobSeekers::AssignAgencyPerson::NotAJobDeveloper
        @agency_person.errors[:person] << 'cannot be assigned as Job Developer unless person has that role.'
        render :edit
      rescue JobSeekers::AssignAgencyPerson::NotACaseManager
        @agency_person.errors[:person] << 'cannot be assigned as Case Manager unless person has that role.'
        render :edit
      end
    else
      unless @agency_person.errors[:agency_admin].empty?

        # If the :agency_admin error key was set by the model this means that
        # the agency person being edited is the sole agency admin (AA), and that
        # role was unchecked in the edit view. Removing the sole AA is not allowed.
        # In this case, reset the AA role.

        @agency_person.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:AA])
      end
      render :edit
    end
  end

  def assign_job_seeker
    # Assign agency person, in specified role, to the job seeker

    @agency_person = AgencyPerson.find(params[:id])
    self.action_description = 'assign a job seeker'
    authorize @agency_person

    role_key = params[:agency_role].to_sym

    @job_seeker = JobSeeker.find(params[:job_seeker_id])

    begin
      JobSeekers::AssignAgencyPerson.new.call(
        @job_seeker,
        role_key,
        @agency_person
      )
    rescue JobSeekers::AssignAgencyPerson::NotAJobDeveloper
      return render(
        json: { message: 'Agency Person is not a job developer' },
        status: 403
      )
    rescue JobSeekers::AssignAgencyPerson::NotACaseManager
      return render(
        json: { message: 'Agency Person is not a case manager' },
        status: 403
      )
    rescue JobSeekers::AssignAgencyPerson::InvalidRole
      return render(
        json: { message: 'Unknown agency role specified' },
        status: 400
      )
    end

    if request.xhr?
      render partial: 'job_seekers/assigned_agency_person',
             locals: { job_seeker: @job_seeker,
                       agency_person: @agency_person,
                       agency_role: params[:agency_role] }
    else
      redirect_to job_seeker_path(@job_seeker)
    end
  end

  def edit_profile
    @agency_person = AgencyPerson.find(params[:id])

    self.action_description = "edit agency person's profile"
    authorize @agency_person
  end

  def update_profile
    @agency_person = AgencyPerson.find(params[:id])
    self.action_description = "edit agency person's profile"
    authorize @agency_person

    person_params = handle_user_form_parameters agency_person_params
    if @agency_person.update_attributes(person_params)
      bypass_sign_in(@agency_person.user, scope: :user)

      # Check if user attempted to update the email address
      if @agency_person.unconfirmed_email?
        flash[:warning] = 'Please check your inbox to confirm your email address'
      else
        flash[:notice] = 'Your profile was updated successfully.'
      end

      redirect_to home_agency_person_path(@agency_person)
    else
      render :edit_profile
    end
  end

  def destroy
    person = AgencyPerson.find(params[:id])

    self.action_description = 'destroy agency person'
    authorize person

    if person.user != current_user
      person.destroy
      flash[:notice] = "Person '#{person.full_name(last_name_first: false)}' deleted."
    else
      flash[:alert] = 'You cannot delete yourself.'
    end
    redirect_to agency_admin_home_path
  end

  def list_js_cm
    raise 'Unsupported request' if not request.xhr?

    @agency_person = AgencyPerson.find(params[:id])

    self.action_description = 'access job seekers assigned to CM'
    authorize @agency_person

    @people_type_cm = params[:people_type] || 'jobseeker-cm'

    @people = []
    @people = display_job_seekers @people_type_cm, @agency_person

    render partial: 'agency_people/assigned_job_seekers',
           locals: { jobseekers: @people,
                     controller_action: 'list_js_cm',
                     people_type: @people_type_cm,
                     agency_person: @agency_person }
  end

  def list_js_jd
    raise 'Unsupported request' if not request.xhr?

    @agency_person = AgencyPerson.find(params[:id])

    self.action_description = 'access job seekers assigned to JD'
    authorize @agency_person

    @people_type_jd = params[:people_type] || 'jobseeker-jd'

    @people = []
    @people = display_job_seekers @people_type_jd, @agency_person

    render partial: 'agency_people/assigned_job_seekers',
           locals: { jobseekers: @people,
                     controller_action: 'list_js_jd',
                     people_type: @people_type_jd,
                     agency_person: @agency_person }
  end

  def list_js_without_jd
    raise 'Unsupported request' if not request.xhr?

    agency_person = AgencyPerson.find(params[:id])

    self.action_description = 'access job seekers without a JD'
    authorize agency_person

    people_type_without_jd = params[:people_type] || 'jobseeker-without-jd'

    people = []
    people = display_job_seekers people_type_without_jd, agency_person

    render partial: 'agency_people/assigned_job_seekers',
           locals: { jobseekers: people,
                     controller_action: 'list_js_without_jd',
                     people_type: people_type_without_jd,
                     agency_person: agency_person }
  end

  def list_js_without_cm
    raise 'Unsupported request' if not request.xhr?

    agency_person = AgencyPerson.find(params[:id])

    self.action_description = 'access job seekers without a CM'
    authorize agency_person

    people_type_without_cm = params[:people_type] || 'jobseeker-without-cm'

    people = []
    people = display_job_seekers people_type_without_cm, agency_person

    render partial: 'agency_people/assigned_job_seekers',
           locals: { jobseekers: people,
                     controller_action: 'list_js_without_cm',
                     people_type: people_type_without_cm,
                     agency_person: agency_person }
  end

  # my job_seeker list as a logged-in job developer
  def my_js_as_jd
    raise 'Unsupported request' if not request.xhr?

    term = params[:q] || {}
    term = term[:term] || ''
    term = term.downcase
    my_js = pets_user.job_seekers.consent.select { |js| js.job_developer == pets_user }
                     .sort { |a, b| a.full_name <=> b.full_name }
    if my_js.blank?
      render json: { message: 'You do not have job seekers!' }, status: 403
    else
      list_js = []
      my_js.each do |js|
        # condition for search term
        if js.full_name.downcase =~ /#{term}/
          if js.resumes.blank?
            list_js << { id: js.id, text: js.full_name, disabled: 'disabled' }
          else
            list_js << { id: js.id, text: js.full_name }
          end
        end
      end
      render json: { results: list_js }
    end
  end

  def my_profile
    @agency_person = AgencyPerson.find(params[:id])
    authorize @agency_person
  end

  private

  def agency_person_params
    params.require(:agency_person).permit(:first_name, :last_name, :email,
                                          :branch_id, :phone,
                                          agency_role_ids: [],
                                          job_category_ids: [],
                                          as_jd_job_seeker_ids: [],
                                          as_cm_job_seeker_ids: [])
  end
end
