class JobSeekerPolicy < ApplicationPolicy
  def update?
    # account owner
    # job seeker's case manager
    # job seeker's job developer
    user == record || user == record.case_manager || user == record.job_developer
  end

  def edit?
    update?
  end

  def home?
    # account owner
    user == record
  end

  def index?
    # all agency people
    user.is_a?(AgencyPerson)
  end

  def show?
    # all agency people
    # all company people
    user ==  user.is_a?(AgencyPerson) || user.is_a?(CompanyPerson)
  end

  def destroy?
    # account's owner
    # agency admin
    user == record || user.is_agency_admin?(user.try(:agency))
  end

  def create?
    # unlogged in user
    # agency person
    user.nil? || user.is_a?(AgencyPerson)
  end

  def new?
    create?
  end

  def preview_info?
    user == record.job_developer
  end

  def allow?
    user.nil? || user == record
  end

  def apply?
    # job seeker's job developer with approval from job seeker
    # job seeker himself
    (record.consent && record.job_developer == user) || user == record
  end

  def permitted_attributes
    if user == record
      [ :first_name,
        :last_name,
        :email,
        :phone,
        :password,
        :password_confirmation,
        :year_of_birth,
        :resume,
        :consent,
        :job_seeker_status_id,
        address_attributes: [:id, :street, :city, :zipcode, :state]
      ]
    elsif (user == record.case_manager) || (user == record.job_developer)
      [ :first_name,
        :last_name,
        :email,
        :phone,
        :resume,
        :consent,
        :job_seeker_status_id,
        address_attributes: [:id, :street, :city, :zipcode, :state]
      ]
    end
  end
  def download_resume?
    User.is_company_person?(user) &&
    record.job_applications.where(job: user.company.jobs.active).exists?
  end
end
