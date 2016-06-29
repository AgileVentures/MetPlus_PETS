class CompanyPerson < ActiveRecord::Base
  acts_as :user
  belongs_to :company
  belongs_to :address
  has_and_belongs_to_many :company_roles,
                          join_table: 'company_people_roles',
                          autosave: false

  STATUS = { PND:   'Pending', # Company has registered but not yet approved
             IVT:   'Invited', # Company approved, invite sent to confirm account
             ACT:   'Active',
             INACT: 'Inactive',
             DENY:  'Registration Denied'} # Company registration denied

  validates :status, inclusion: STATUS.values

  validate :not_removing_sole_company_admin, on: :update

  scope :all_company_people, ->(company) {
    where(company_id: company.id).joins(:user).order('users.last_name')
  }

  def not_removing_sole_company_admin
    # This validation is to prevent the removal of a sole company admin -
    # which would result in no CompanyPerson able to perform the admin role.

    # If the CA role is set for this person we are OK
    company_roles.each { |role| return if role.role == CompanyRole::ROLE[:CA] }

    errors[:company_admin] << 'cannot be unset for sole company admin.' unless
                      other_company_admin?
  end

  def other_company_admin?
    admins = Company.company_admins(company)

    (admins.count > 1) || (admins.count == 1 && !admins.include?(self))
  end

  def sole_company_admin?
    # Is this person even an admin?
    return false unless company_roles.pluck(:role).include? CompanyRole::ROLE[:CA]

    not other_company_admin?
  end


  def is_company_admin? company
    return false if self.company != company
    has_role?(:CA)
  end

  def is_company_contact? company
    return false if self.company != company
    has_role?(:CC)
  end

  def is_company_person? company
    self.company == company
  end

  private
  def has_role? role
    company_roles.pluck(:role).include?CompanyRole::ROLE[role]
  end
end
