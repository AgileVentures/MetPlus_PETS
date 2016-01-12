class CompanyRegistrationsController < ApplicationController

  def new
    @company = Company.new
    @company.addresses.build
    @company.company_people.build
  end

  def show
    @company = Company.find(params[:id])
  end

  def destroy
    company = Company.find(params[:id])
    company.destroy
    flash[:notice] = "Registration for '#{company.name}' deleted."
    redirect_to root_path
  end

  def create
    @company = Company.new
    # Assign attributes for Company and (nested) attributes for Address and CompanyPerson
    @company.assign_attributes(company_params)

    # Ensure that company contact does *not* recieve a confirmation email
    @company.company_people[0].user.skip_confirmation_notification!

    # Ensure that contact cannot log in
    @company.company_people[0].user.approved = false

    @company.status                   = Company::STATUS[:PND]
    @company.company_people[0].status = CompanyPerson::STATUS[:PND]

    @company.agencies << Agency.first

    if @company.save
      flash.notice = "You have successfully registered your company! An agency representative will be contacting you shortly!" # need more informative message
      CompanyMailer.pending_approval(@company,
                                     @company.company_people[0]).deliver_now
      render :confirmation
    else
      @model_errors = @company.errors
      render :new
    end
  end

  def approve
    # Approve the company's registration request.
    # There should be only one CompanyPerson associated with the company -
    # this is the 'company contact' included in the registration request.
    company = Company.find(params[:id])
    company_person = company.company_people[0]

    company.status          = Company::STATUS[:ACT]
    company_person.status   = CompanyPerson::STATUS[:ACT]
    company_person.approved = true
    company.save
    company_person.save

    # Send notice of registration acceptance (CompanyMailer)
    CompanyMailer.registration_approved(company, company_person).deliver_now

    # Send account confirmation email (Devise)
    company_person.user.send_confirmation_instructions

    flash[:notice] = "Company contact has been notified of registration approval."
    redirect_to company_registration_path(company)

  end

  def deny
    # Deny the company's registration request.
    company = Company.find(params[:id])
    company_person = company.company_people[0]

    company.status = Company::STATUS[:DENY]
    company.save

    render :partial => 'companies/company_status',
           :locals => {company: company} if request.xhr?

    # Send notice of registration denial
    CompanyMailer.registration_denied(company,
                  company_person, params[:email_text]).deliver_now
  end

  private
  def company_params
    params.require(:company).permit(:name, :email, :phone,
    :website, :ein, :description,
    company_people_attributes: [:first_name, :last_name, :phone, :email,
                                :password, :password_confirmation],
    addresses_attributes: [:street, :city, :zipcode])
  end

end
