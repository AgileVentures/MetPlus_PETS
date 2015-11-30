class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable,
         :validatable
   actable
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
   
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
    
    def self.is_company_admin?(user)
      return false unless user.actable_type == "CompanyPerson"
      user.actable.company_roles.pluck(:role).include? CompanyRole::ROLE[:EA]
    end
    
    def self.is_company_contact?(user)
      return false unless user.actable_type == "CompanyPerson"
      user.actable.company_roles.pluck(:role).include? CompanyRole::ROLE[:EC]
    end
    
    def self.full_name(person)
      "#{person.first_name} #{person.last_name}"
    end

end
