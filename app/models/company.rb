class Company < ActiveRecord::Base
  has_many :company_people, dependent: :destroy
    accepts_nested_attributes_for :company_people

  has_many :jobs

  has_many :addresses, as: :location, dependent: :destroy
    accepts_nested_attributes_for :addresses

  has_and_belongs_to_many :agencies


  validates :ein,   :ein_number => true
  validates_uniqueness_of :ein, case_sensitive: false,
                  message: 'has already been registered'
  validates :phone, :phone => true
  validates :fax, :phone => true, allow_blank: true
  validates :email, :email => true
  validates :website, :website => true
  validates_presence_of :name
  validates :job_email, :email => true, allow_blank: true

  STATUS = { PND:   'Pending Registration', # Company has registered but not yet approved
             ACT:   'Active',
             INACT: 'Inactive',
             DENY:  'Registration Denied'}

  validates :status, inclusion: STATUS.values


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
