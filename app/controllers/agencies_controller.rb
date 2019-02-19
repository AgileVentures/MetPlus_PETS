class AgenciesController < ApplicationController
  before_action :user_logged!

  def edit
    @agency = Agency.find(params[:id])
    self.action_description = "edit #{@agency.name} agency"
    authorize @agency
  end

  def update
    @agency = Agency.find(params[:id])
    self.action_description = "edit #{@agency.name} agency"
    authorize @agency
    @agency.assign_attributes(agency_params)
    if @agency.save
      flash[:notice] = "Agency was successfully updated."
      redirect_to agency_admin_home_path
    else
      render :edit
    end
  end

  private

  def agency_params
    params.require(:agency).permit(:name, :display_name, :website, :phone, :fax,
                                   :email, :description)
  end
end
