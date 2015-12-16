class AgencyPeopleController < ApplicationController

  def new
    # THIS CODE IS NOT READY FOR TESTING
    @agency = Agency.this_agency(current_user)
    @agency_person = AgencyPerson.new
  end
  
  def create
    # THIS CODE IS NOT READY FOR TESTING
    @agency = Agency.find(params[:agency_id])
    @agency_person = AgencyPerson.new
    @agency_person.assign_attributes(agency_person_params)
    @agency.agency_people << @agency_person
    if @agency_person.valid?
      @agency_person.save
      flash[:notice] = "Person was successfully created."
      redirect_to agency_admin_home_path
    else
      @model_errors = @agency_person.errors
      render :new
    end
  end

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
      if @agency_person.errors[:agency_admin]
        
        # If the :agency_error was set by the model this means that the agency person
        # being edited is the sole agency admin (AA), and that role was unchecked in the
        # edit view. Removing the sole AA is not allowed.
        # In this case, reset the AA role and add a flash message.
        
        @agency_person.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:AA])
        flash.now[:warning] = 'Admin agency role reset - see error message'
      end
      @model_errors = @agency_person.errors
      render :edit
    end
  end

  def destroy
  end
  
  private
  
  def agency_person_params
    params.require(:agency_person).permit(:first_name, :last_name, :branch_id,
                          agency_role_ids: [], job_category_ids: [],
                          job_seeker_ids: [])                    
  end
  
end
