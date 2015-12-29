class AgencyPeopleController < ApplicationController

  def show
    @agency_person = AgencyPerson.find(params[:id])
  end

  def edit
    @agency_person = AgencyPerson.find(params[:id])
  end

  def update
    @agency_person = AgencyPerson.find(params[:id])
    @agency_person.assign_attributes(agency_person_params)
    
    if @agency_person.save
      flash[:notice] = "Agency person was successfully updated."
      redirect_to agency_person_path(@agency_person)
    else
      unless @agency_person.errors[:agency_admin].empty?
        
        # If the :agency_admin error key was set by the model this means that 
        # the agency person being edited is the sole agency admin (AA), and that 
        # role was unchecked in the edit view. Removing the sole AA is not allowed.
        # In this case, reset the AA role and add a flash message.
        
        @agency_person.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:AA])
      end
      unless @agency_person.errors[:job_seeker].empty?
        
        # If the :job_seeker error key was set by the model this means that the agency person
        # being edited does not have the 'Job Developer' role but has been assigned to be the
        # primary job developer for one or more job seekers.
        
        @agency_person.job_seekers = []
      end
      @model_errors = @agency_person.errors
      render :edit
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
    params.require(:agency_person).permit(:first_name, :last_name, :branch_id,
                          agency_role_ids: [], job_category_ids: [],
                          job_seeker_ids: [])                    
  end
  
end
