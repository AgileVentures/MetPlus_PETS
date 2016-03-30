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

    @company.company_people[0].company_roles <<
                    CompanyRole.find_by_role(CompanyRole::ROLE[:CA])

    @company.agencies << Agency.first

    if @company.save
      flash.notice = "Thank you for your registration request. " +
         " We will review your request and get back to you shortly."
      CompanyMailer.pending_approval(@company,
                                     @company.company_people[0]).deliver_now
      Event.create(:COMP_REGISTER,
                   name: @company.name, id: @company.id)

      render :confirmation
    else
      @model_errors = @company.errors
      render :new
    end
  end

  def edit
    @company = Company.find(params[:id])
    @company.build_address unless @company.addresses
  end

  def update
    @company = Company.find(params[:id])

    reg_params = company_params
    if reg_params[:company_people_attributes]['0'][:password].empty?
      reg_params[:company_people_attributes]['0'].delete :password
      reg_params[:company_people_attributes]['0'].delete :password_confirmation
    end

    changed_email = (@company.company_people[0].email !=
            reg_params[:company_people_attributes]['0'][:email])

    # Do not create a new email confirmation token and
    # do not send an email confirmation email
    # (If config.reconfirmable = true in Devise initializer file, the default
    # behavior will be to create a new token and send confirmation email.)
    @company.company_people[0].user.skip_reconfirmation!

    if @company.update_attributes(reg_params)
      flash[:notice] = "Registration was successfully updated."
      # Send pending-approval email to company contact if the contact
      # email address was changed
      if changed_email
        CompanyMailer.pending_approval(@company,
                                @company.company_people[0]).deliver_now
      end
      redirect_to agency_admin_home_path
    else
      @model_errors = @company.errors
      render :edit
    end
  end

  def approve
    # Approve the company's registration request.
    # There should be only one CompanyPerson associated with the company -
    # this is the 'company contact' included in the registration request.
    company = Company.find(params[:id])
    company.status          = Company::STATUS[:ACT]
    company.save

    company_person = company.company_people[0]
    company_person.status   = CompanyPerson::STATUS[:ACT]
    company_person.approved = true
    company_person.save

    # Send notice of registration acceptance (CompanyMailer)
    CompanyMailer.registration_approved(company, company_person).deliver_now

    # Send account confirmation email (Devise)
    company_person.user.send_confirmation_instructions

    flash[:notice] = "Company contact has been notified of registration approval."
    redirect_to company_path(company.id)

  end

  def deny
    # Deny the company's registration request.
    company = Company.find(params[:id])
    company_person = company.company_people[0]

    company.status                   = Company::STATUS[:DENY]
    company.company_people[0].status = CompanyPerson::STATUS[:DENY]
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
    company_people_attributes: [:id, :first_name, :last_name,
                        :phone, :email, :title,
                        :password, :password_confirmation],
    addresses_attributes: [:id, :street, :city, :zipcode])
  end

end
