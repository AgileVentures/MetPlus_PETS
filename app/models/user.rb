class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable,
         :validatable
   actable
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
   validates   :email, :email => true

   def self.is_job_seeker?(user)
     user.actable_type == 'JobSeeker'
   end

   def self.is_job_developer?(user)
      return false unless user.actable_type == "AgencyPerson"
      user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:JD]
   end

   def self.is_case_manager?(user)
      return false unless user.actable_type == "AgencyPerson"
      user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:CM]
   end

    def self.is_agency_admin?(user)
      return false unless user.actable_type == "AgencyPerson"
      user.actable.agency_roles.pluck(:role).include? AgencyRole::ROLE[:AA]
    end

    def self.is_agency_person?(user)
      is_job_developer?(user) || is_case_manager?(user) || is_agency_admin?(user)
    end

    def self.is_company_admin?(user)
      return false unless user.actable_type == "CompanyPerson"
      user.actable.company_roles.pluck(:role).include? CompanyRole::ROLE[:CA]
    end

    def self.is_company_contact?(user)
      return false unless user.actable_type == "CompanyPerson"
      user.actable.company_roles.pluck(:role).include? CompanyRole::ROLE[:CC]
    end

    def self.is_company_person?(user)
      is_company_contact?(user) || is_company_admin?(user)
    end

    def full_name(order={:last_name_first => true})
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
    self.try(:actable).nil? ? self : self.actable
  end

  def is_job_seeker?
    false
  end

  def is_job_developer? agency
    false
  end

  def is_case_manager? agency
    false
  end

  def is_agency_admin? agency
    false
  end

  def is_agency_person? agency
    false
  end

  def is_company_admin? company
    false
  end

  def is_company_contact? company
    false
  end

  def is_company_person? company
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

end
