class Company < ActiveRecord::Base
  has_many :company_people, dependent: :destroy
    accepts_nested_attributes_for :company_people

  has_many :jobs

  has_many :addresses, as: :location, dependent: :destroy
    accepts_nested_attributes_for :addresses, reject_if: :all_blank,
                                  allow_destroy: true

  has_and_belongs_to_many :agencies

  enum status: [:pending_registration, :active, :inactive, :registration_denied]
  has_many :status_changes, as: :entity, dependent: :destroy


  validates :ein,   :ein_number => true
  validates_uniqueness_of :ein, case_sensitive: false,
                  message: 'has already been registered'
  validates :phone, :phone => true
  validates :fax, :fax => true, allow_blank: true
  validates :email, :email => true
  validates :website, :website => true
  validates_presence_of :name
  validates_presence_of :job_email
  validates :job_email, :email => true

  def pending_registration
    pending_registration!
    StatusChange.update_status_history(self, :pending_registration)
  end

  def active
    active!
    StatusChange.update_status_history(self, :active)
  end

  def registration_denied
    registration_denied!
    StatusChange.update_status_history(self, :registration_denied)
  end

  def self.all_with_active_jobs
    companies = []
    Company.active.order(:name).each do |cmpy|
      unless cmpy.jobs.where(status: 'active').empty?
        companies << cmpy
      end
    end
    companies
  end

  def self.company_admins(company)
    find_users_with_role(company, CompanyRole::ROLE[:CA])
  end

  def sole_company_admin?
    # Is this person even an admin?
    return false unless company_roles.pluck(:role).include? CompanyRole::ROLE[:CA]

    not other_company_admin?
  end

  def other_company_admin?
    admins = Company.company_admins(company)

    (admins.count > 1) || (admins.count == 1 && !admins.include?(self))
  end

  def people_on_role role
    users = []
    company_people.each do |person|
      users << person if person.company_roles &&
          person.company_roles.pluck(:role).include?(role)
    end

    users
  end

  private

  def self.find_users_with_role(company, role)
    company.people_on_role role
  end

end
