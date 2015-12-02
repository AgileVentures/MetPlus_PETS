class BranchesController < ApplicationController
  def show
    @branch = Branch.find(params[:id])
  end
  
  def create
    @agency = Agency.find(params[:agency_id])
    @branch = Branch.new
    @branch.assign_attributes(branch_params)
    @agency.branches << @branch
    if @branch.valid?
      @branch.save
      flash[:success] = "Branch was successfully created."
      redirect_to agency_admin_home_path
    else
      @model_errors = @branch.errors
      render :new
    end
  end

  def new
    @agency = Agency.this_agency(current_user)
    @branch = Branch.new
    @branch.build_address
  end

  def edit
    @branch = Branch.find(params[:id])
    @branch.build_address unless @branch.address
  end

  def update
    @branch = Branch.find(params[:id])
    @branch.assign_attributes(branch_params)
    if @branch.valid?
      @branch.save
      flash[:success] = "Branch was successfully updated."
      redirect_to branch_path(@branch)
    else
      @model_errors = @branch.errors
      render :edit
    end
  end

  def destroy
    branch = Branch.find(params[:id])
    branch.destroy
    flash[:success] = "Branch '#{branch.code}' deleted."
    redirect_to agency_admin_home_path
  end
  
  private
  
  def branch_params
    params.require(:branch).permit(:code, 
            address_attributes: [:id, :street, :city, :zipcode])
                                    
  end
  
end
