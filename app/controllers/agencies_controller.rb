class AgenciesController < ApplicationController
  
  def edit
    @agency = Agency.find(params[:id])
  end

  def update
    @agency = Agency.find(params[:id])
    @agency.assign_attributes(agency_params)
    if @agency.valid?
      @agency.save
      flash[:notice] = "Agency was successfully updated."
      redirect_to agency_admin_home_path
    else
      @model_errors = @agency.errors
      render :edit
    end
  end
  
  def agency_params
    params.require(:agency).permit(:name, :website, :phone, :fax,
                                   :email, :description)
  end
  
end
