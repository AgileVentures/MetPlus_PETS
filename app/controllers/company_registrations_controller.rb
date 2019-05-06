class CompanyRegistrationsController < ApplicationController
  include UserParameters
  include CompanyPeopleViewer

  before_action :user_logged!, except: [:new, :create]
  before_action :load_and_authorize_company, except: [:new, :create]

  def new
    @company = Company.new
    @company.addresses.build
    @company.company_people.build
  end

  def show
    authorize company_registration(@company)
    @company_admins = Company.company_admins(@company)
    @people_type    = 'company-all'
  end

  def destroy
    @company.destroy
    flash[:notice] = "Registration for '#{@company.name}' deleted."
    redirect_to root_path
  end

  def create
    @company = Company.new
    # Assign attributes for Company and (nested) attributes
    # for Address and CompanyPerson
    @company.assign_attributes(company_params)

    # Ensure that company contact does *not* recieve a confirmation email
    @company.company_people[0].user.skip_confirmation_notification!

    # Ensure that contact cannot log in
    @company.company_people[0].user.approved = false

    @company.company_people[0].company_roles <<
      CompanyRole.find_by(role: CompanyRole::ROLE[:CC])
    @company.company_people[0].company_roles <<
      CompanyRole.find_by(role: CompanyRole::ROLE[:CA])

    # MULTIPLE AGENCIES: the line below needs to change
    @company.agencies << Agency.first

    if @company.save
      @company.pending_registration
      @company.company_people[0].company_pending
      flash.notice = 'Thank you for your registration request. ' \
         ' We will review your request and get back to you shortly.'

      Event.create(:COMP_REGISTER, @company)
      render :confirmation
    else
      render :new
    end
  end

  def edit
    @company.build_address unless @company.addresses
  end

  def update
    reg_params = company_params
    reg_params[:company_people_attributes]['0'] =
      handle_user_form_parameters(reg_params[:company_people_attributes]['0'])

    changed_email = (@company.company_people[0].email !=
            reg_params[:company_people_attributes]['0'][:email])

    # Do not create a new email confirmation token and
    # do not send an email confirmation email
    # (If config.reconfirmable = true in Devise initializer file, the default
    # behavior will be to create a new token and send confirmation email.)
    @company.company_people[0].user.skip_reconfirmation!

    if @company.update_attributes(reg_params)
      flash[:notice] = 'Registration was successfully updated.'
      # Send pending-approval email to company contact if the contact
      # email address was changed
      if changed_email
        CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                        .perform_later(Event::EVT_TYPE[:COMP_REGISTER],
                                       @company,
                                       @company.company_people[0])
      end
      redirect_to agency_admin_home_path
    else
      render :edit
    end
  end

  def approve
    Companies::ApproveCompanyRegistration.new.call(@company)

    flash[:notice] =
      'Company contact has been notified of registration approval.'
    redirect_to @company
  end

  def deny
    Companies::DenyCompanyRegistration.new.call(@company, params[:email_text])

    if request.xhr?
      render partial: 'companies/company_status',
             locals: { company: @company, admin_aa: true }
    end
  end

  private

  def company_registration(company)
    CompanyRegistration.new company
  end

  def load_and_authorize_company
    @company = Company.find(params[:id])
    authorize company_registration(@company)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path,
                alert: "The company you're looking for doesn't exist"
  end

  def company_params
    params
      .require(:company)
      .permit(:name, :email, :phone, :fax, :website,
              :ein, :description, :job_email,
              company_people_attributes:
                [:id, :first_name, :last_name, :phone,
                 :email, :title, :password, :password_confirmation],
              addresses_attributes:
                [:id, :street, :city, :zipcode, :state, :_destroy])
  end
end
