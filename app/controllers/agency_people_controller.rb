class AgencyPeopleController < ApplicationController

  include UserParameters
  include JobSeekersViewer

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
    @people_type_cm = 'jobseeker-cm'
    @people_type_jd = 'jobseeker-jd'
    @js_without_jd = JobSeeker.paginate(:page=> params[:js_without_jd_page], :per_page=>5).js_without_jd
    @js_without_cm = JobSeeker.paginate(:page=> params[:js_without_cm_page], :per_page=>5).js_without_cm
    @your_jobseekers_jd = JobSeeker.your_jobseekers_jd(@agency_person)
    @your_jobseekers_cm = JobSeeker.your_jobseekers_cm(@agency_person)
  end

  def update
    @agency_person = AgencyPerson.find(params[:id])
    model_params = agency_person_params
    jd_job_seeker_ids = model_params.delete(:as_jd_job_seeker_ids)
    cm_job_seeker_ids = model_params.delete(:as_cm_job_seeker_ids)

    # Find newly-assigned job seekers for notifying the agency person (as JD)
    new_jd_job_seeker_ids = new_job_seeker_ids(@agency_person,
                                               jd_job_seeker_ids, :JD)

    # Find newly-assigned job seekers for notifying the agency person (as CM)
    new_cm_job_seeker_ids = new_job_seeker_ids(@agency_person,
                                               cm_job_seeker_ids, :CM)

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
      # notify agency person of new JS assignments
      notify_ap_new_js_assignments @agency_person,
                                   new_jd_job_seeker_ids, :JD

      notify_ap_new_js_assignments @agency_person,
                                   new_cm_job_seeker_ids, :CM

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

  def list_js_cm
    raise 'Unsupported request' if not request.xhr?

    @agency_person= AgencyPerson.find(params[:id])

    @people_type_cm = params[:people_type] || 'jobseeker-cm'

    @people = []
    @people = display_job_seekers @people_type_cm, @agency_person

    render :partial => 'agency_people/assigned_job_seekers',
                       locals: {jobseekers: @people,
                                controller_action:'list_js_cm',
                                people_type: @people_type_cm,
                                agency_person: @agency_person}
  end
 
  def list_js_jd
    raise 'Unsupported request' if not request.xhr?

    @agency_person= AgencyPerson.find(params[:id])

    @people_type_jd = params[:people_type] || 'jobseeker-jd'

    @people = []
    @people = display_job_seekers @people_type_jd, @agency_person

    render :partial => 'agency_people/assigned_job_seekers',
                       locals: {jobseekers: @people,
                                controller_action:'list_js_jd',
                                people_type: @people_type_jd,
                                agency_person: @agency_person}
  end


  private

  def agency_person_params
    params.require(:agency_person).permit(:first_name, :last_name, :branch_id, :phone,
                          agency_role_ids: [], job_category_ids: [],
                          as_jd_job_seeker_ids: [],
                          as_cm_job_seeker_ids: [])
  end

  def new_job_seeker_ids agency_person, job_seeker_ids, role_key
    # job_seeker_ids comes in from params.  Find and return the ids of
    # job seekers who are represented in params but not yet associated
    # with the agency person in the indicated role

    unless job_seeker_ids.empty?
      new_job_seeker_ids = job_seeker_ids.map { |id| id.to_i }
      new_job_seeker_ids.delete(0)
      case role_key
      when :JD
        current_js_ids = agency_person.as_jd_job_seeker_ids
      when :CM
        current_js_ids = agency_person.as_cm_job_seeker_ids
      end
      new_job_seeker_ids.keep_if do |js_id|
        not current_js_ids.include? js_id
      end
    end
    return new_job_seeker_ids
  end

  def notify_ap_new_js_assignments agency_person, job_seeker_ids, role_key
    if job_seeker_ids
      job_seeker_ids.each do |js_id|
        obj = Struct.new(:job_seeker, :agency_person)
        case role_key
        when :JD
          Event.create(:JS_ASSIGN_JD, obj.new(JobSeeker.find(js_id),
                                              @agency_person))
        when :CM
          Event.create(:JS_ASSIGN_CM, obj.new(JobSeeker.find(js_id),
                                              @agency_person))
        end
      end
    end
  end

end
