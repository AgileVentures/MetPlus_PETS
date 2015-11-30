class BranchesController < ApplicationController
  def show
    @branch = Branch.find(params[:id])
  end
  
  def create
  end

  def new
  end

  def edit
  end

  def update
  end

  def destroy
    branch = Branch.find(params[:id])
    branch.destroy
    flash[:success] = "Branch '#{branch.code}' deleted."
    redirect_to agency_admin_home_path
  end
end
