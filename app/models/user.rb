class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable,
         :validatable
  actable
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates   :phone, phone: true
  validates   :email, email: true

  def self.job_seeker?(user)
    user.actable_type == 'JobSeeker'
  end

  def self.job_developer?(user)
    return false unless user.actable_type == 'AgencyPerson'
    user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:JD]
  end

  def self.case_manager?(user)
    return false unless user.actable_type == 'AgencyPerson'
    user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:CM]
  end

  def self.agency_admin?(user)
    return false unless user.actable_type == 'AgencyPerson'
    user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:AA]
  end

  def self.agency_person?(user)
    job_developer?(user) || case_manager?(user) || agency_admin?(user)
  end

  def self.company_admin?(user)
    company_role?(user, :CA)
  end

  def self.company_contact?(user)
    company_role?(user, :CC)
  end

  def self.company_person?(user)
    company_contact?(user) || company_admin?(user)
  end

  def full_name(order = { last_name_first: true })
    return "#{last_name}, #{first_name}" if order[:last_name_first]
    "#{first_name} #{last_name}"
  end

  # Devise controller method overrides ...
  # ...see: https://github.com/plataformatec/devise/wiki/
  #             How-To:-Require-admin-to-activate-account-before-sign_in

  def active_for_authentication?
    super && approved?
  end

  def pets_user
    try(:actable).nil? ? self : actable
  end

  def job_seeker?
    false
  end

  def job_developer?(_agency)
    false
  end

  def case_manager?(_agency)
    false
  end

  def agency_admin?(_agency)
    false
  end

  def agency_person?(_agency)
    false
  end

  def company_admin?(_company)
    false
  end

  def company_contact?(_company)
    false
  end

  def company_person?(_company)
    false
  end

  def inactive_message
    if !approved? && actable.try(:company_pending?)
      :signed_up_but_not_approved
    elsif !approved? && actable.try(:company_denied?)
      :not_approved
    else
      super
    end
  end

  def self.company_role?(user, role)
    return false if user.nil?
    return false unless user.actable_type == 'CompanyPerson'
    user.actable.company_roles.pluck(:role).include? CompanyRole::ROLE[role]
  end
end
