class AgencyPeopleController < ApplicationController
  def create
  end

  def new
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
    
    if @agency_person.valid?
      @agency_person.save
      flash[:notice] = "Agency person was successfully updated."
      redirect_to agency_person_path(@agency_person)
    else
      @model_errors = @agency_person.errors
      render :edit
    end
  end

  def destroy
  end
  
  private
  
  def agency_person_params
    params.require(:agency_person).permit(:first_name, :last_name, :branch_id,
                          agency_role_ids: [], job_category_ids: [])                    
  end
  
end
