class CompaniesController < ApplicationController

  def show
    @company = Company.find(params[:id])
  end

  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Company '#{company.name}' deleted."
    redirect_to root_path
  end

  def edit
    @company = Company.find(params[:id])

  end

  def update
    @company = Company.find(params[:id])
    @company.assign_attributes(company_params)
    if @company.valid?
      @company.save
      flash[:notice] = "company was successfully updated."
      redirect_to company_path(@company)
    else
      @model_errors = @company.errors
      render :edit
    end
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone, :fax,
    :website, :ein, :description,
    company_people_attributes: [:id, :first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode, :state])
  end
end
