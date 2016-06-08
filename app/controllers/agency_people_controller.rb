class AgencyPeopleController < ApplicationController

  include UserParameters

  def show
    @agency_person = AgencyPerson.find(params[:id])
  end

  def edit
    @agency_person = AgencyPerson.find(params[:id])
  end

  def home
    @agency_person = AgencyPerson.find(params[:id])
    @agency = @agency_person.agency
    @task_type = 'mine-open'
    @js_without_jd = JobSeeker.paginate(:page=> params[:js_without_jd_page], :per_page=>5).js_without_jd
    @js_without_cm = JobSeeker.paginate(:page=> params[:js_without_cm_page], :per_page=>5).js_without_cm
    @your_jobseekers_jd = JobSeeker.paginate(:page=> params[:your_jobseekers_jd_page], :per_page=> 5).your_jobseekers_jd(@agency_person)
    @your_jobseekers_cm = JobSeeker.paginate(:page=> params[:your_jobseekers_cm_page], :per_page=> 5).your_jobseekers_cm(@agency_person)
  end

  def update
    @agency_person = AgencyPerson.find(params[:id])
    model_params = agency_person_params
    jd_job_seeker_ids = model_params.delete(:as_jd_job_seeker_ids)
    cm_job_seeker_ids = model_params.delete(:as_cm_job_seeker_ids)

    @agency_person.assign_attributes(model_params)

    @agency_person.agency_relations.delete_all

    # Build agency_relations to associate job_seekers to person as Job Developer
    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[:JD]).id
    jd_job_seeker_ids.each do |js_id|
      @agency_person.agency_relations <<
          AgencyRelation.new(agency_role_id: role_id,
                             job_seeker_id: js_id) unless js_id.empty?
    end

    # Build agency_relations to associate job_seekers to person as Case Manager
    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[:CM]).id
    cm_job_seeker_ids.each do |js_id|
      @agency_person.agency_relations <<
          AgencyRelation.new(agency_role_id: role_id,
                             job_seeker_id: js_id) unless js_id.empty?
    end

    if @agency_person.save
      flash[:notice] = "Agency person was successfully updated."
      redirect_to agency_person_path(@agency_person)
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
    @job_seeker    = JobSeeker.find(params[:job_seeker_id])

    role_key = params[:agency_role].to_sym

    # confirm that agency person has this role and assign person to job seeker
    case role_key
    when :JD
      return render(json: {:message => 'Agency Person is not a job developer'},
                    status: 403) unless
                    @agency_person.is_job_developer? @agency_person.agency

      @job_seeker.assign_job_developer(@agency_person, @agency_person.agency)

    when :CM
      return render(json: {:message => 'Agency Person is not a case manager'},
                    status: 403) unless
                    @agency_person.is_case_manager? @agency_person.agency

      @job_seeker.assign_case_manager(@agency_person, @agency_person.agency)

    else
      return render(json: {:message => 'Unknown agency role specified'},
                    status: 400)
    end

    if request.xhr?
      render :partial => 'job_seekers/assigned_agency_person',
             :locals => {job_seeker: @job_seeker,
                         agency_person: @agency_person,
                         agency_role: params[:agency_role]}
    else
      redirect_to job_seeker_path(@job_seeker)
    end
  end

  def edit_profile
    @agency_person = AgencyPerson.find(params[:id])
  end

  def update_profile
    @agency_person = AgencyPerson.find(params[:id])
    person_params = handle_user_form_parameters agency_person_params
    if @agency_person.update_attributes(person_params)
      sign_in :user, @agency_person.user, bypass: true
      flash[:notice] = "Your profile was updated successfully."
      redirect_to root_path
    else
      render :edit_profile
    end

  end

  def destroy
    person = AgencyPerson.find(params[:id])
    if person.user != current_user
      person.destroy
      flash[:notice] = "Person '#{person.full_name(last_name_first: false)}' deleted."
    else
      flash[:alert] = "You cannot delete yourself."
    end
    redirect_to agency_admin_home_path
  end

  private

  def agency_person_params
    params.require(:agency_person).permit(:first_name, :last_name, :branch_id, :phone,
                          agency_role_ids: [], job_category_ids: [],
                          as_jd_job_seeker_ids: [],
                          as_cm_job_seeker_ids: [])
  end

end
