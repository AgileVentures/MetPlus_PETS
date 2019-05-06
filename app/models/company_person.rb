class CompanyPerson < ApplicationRecord
  acts_as :user
  belongs_to :company
  belongs_to :address
  has_and_belongs_to_many :company_roles,
                          join_table: 'company_people_roles',
                          autosave: false

  enum status: [:company_pending, :invited, :active, :inactive, :company_denied]
  has_many :status_changes, as: :entity, dependent: :destroy

  has_many :jobs, dependent: :nullify

  validate :not_removing_sole_company_admin, on: :update

  def company_pending
    company_pending!
    StatusChange.update_status_history(self, :company_pending)
  end

  def invited
    invited!
    StatusChange.update_status_history(self, :invited)
  end

  def active
    active!
    StatusChange.update_status_history(self, :active)
  end

  def inactive
    inactive!
    StatusChange.update_status_history(self, :inactive)
  end

  def company_denied
    company_denied!
    StatusChange.update_status_history(self, :company_denied)
  end

  scope :all_company_people, ->(company) {
    where(company_id: company.id).joins(:user).order('users.last_name')
  }

  def not_removing_sole_company_admin
    # This validation is to prevent the removal of a sole company admin -
    # which would result in no CompanyPerson able to perform the admin role.

    # If the CA role is set for this person we are OK
    company_roles.each { |role| return if role.role == CompanyRole::ROLE[:CA] }

    errors.add(:company_admin, 'cannot be unset for sole company admin.') unless
                      other_company_admin?
  end

  def other_company_admin?
    admins = Company.company_admins(company)

    (admins.count > 1) || (admins.count == 1 && !admins.include?(self))
  end

  def sole_company_admin?
    # Is this person even an admin?
    return false unless company_roles.pluck(:role).include? CompanyRole::ROLE[:CA]

    !other_company_admin?
  end

  def company_admin?(company)
    return false if self.company != company

    has_role?(:CA)
  end

  def company_contact?(company)
    return false if self.company != company

    has_role?(:CC)
  end

  def company_person?(company)
    self.company == company
  end

  def can_login?
    company.active?
  end

  private

  def has_role?(role)
    company_roles.pluck(:role).include? CompanyRole::ROLE[role]
  end
end
