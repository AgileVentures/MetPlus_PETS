class Company < ApplicationRecord
  has_many :company_people, dependent: :destroy
  accepts_nested_attributes_for :company_people

  has_many :jobs

  has_many :addresses, as: :location, dependent: :destroy
  accepts_nested_attributes_for :addresses, reject_if: :all_blank,
                                            allow_destroy: true

  has_and_belongs_to_many :agencies

  enum status: [:pending_registration, :active, :inactive, :registration_denied]
  has_many :status_changes, as: :entity, dependent: :destroy

  has_many :skills, as: :organization

  validates :ein, ein_number: true
  validates_uniqueness_of :ein, case_sensitive: false,
                                message: 'has already been registered'
  validates :phone, phone: true
  validates :fax, phone: true, allow_blank: true
  validates :email, email: true
  validates :website, website: true
  validates_presence_of :name
  validates_presence_of :job_email
  validates :job_email, email: true

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

  def inactive
    inactive!
    StatusChange.update_status_history(self, :inactive)
  end

  def has_no_jobs?
    !jobs.exists?
  end

  ransacker :status, formatter: proc { |v| statuses[v] }

  def self.all_active_with_jobs
    Company.active.order(:name).joins(:jobs).distinct.all
  end

  def self.company_admins(company)
    find_users_with_role(company, CompanyRole::ROLE[:CA])
  end

  def self.everyone(company)
    company.company_people.joins(:user).order('users.last_name')
  end

  def people_on_role(role)
    users = []
    company_people.each do |person|
      users << person if person.company_roles &&
                         person.company_roles.pluck(:role).include?(role)
    end

    users
  end

  private_class_method

  def self.find_users_with_role(company, role)
    company.people_on_role role
  end
end
