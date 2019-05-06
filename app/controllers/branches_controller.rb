class BranchesController < ApplicationController
  before_action :user_logged!

  def show
    @branch = Branch.find(params[:id])
    self.action_description = "show the branch"
    authorize @branch
  end

  def create
    @agency = Agency.find(params[:agency_id])
    @branch = Branch.new(agency: @agency)

    self.action_description = "create a branch"
    authorize @branch

    @branch.assign_attributes(branch_params)

    if @branch.valid?
      @branch.save
      @agency.branches << @branch
      flash[:notice] = "Branch was successfully created."
      redirect_to agency_admin_home_path
    else
      render :new
    end
  end

  def new
    if Agency.this_agency(current_user).nil?
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_to(root_path) && return
    else
      @agency = Agency.this_agency(current_user)
    end
    @branch = Branch.new(agency: @agency)
    self.action_description = "create a branch"
    authorize @branch
    @branch.build_address
  end

  def edit
    @branch = Branch.find(params[:id])
    self.action_description = "edit the branch"
    authorize @branch
    @branch.build_address unless @branch.address
  end

  def update
    @branch = Branch.find(params[:id])
    self.action_description = "update the branch"
    authorize @branch
    @branch.assign_attributes(branch_params)
    if @branch.valid?
      @branch.save
      flash[:notice] = "Branch was successfully updated."
      redirect_to branch_path(@branch)
    else
      render :edit
    end
  end

  def destroy
    branch = Branch.find(params[:id])
    self.action_description = "destroy the branch"
    authorize branch
    branch.destroy
    flash[:notice] = "Branch '#{branch.code}' deleted."
    redirect_to agency_admin_home_path
  end

  private

  def branch_params
    params.require(:branch).permit(:code,
                                   address_attributes: [:id, :street, :city, :zipcode, :state])
  end
end
