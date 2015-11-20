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
<<<<<<< HEAD


  

  def is_job_seeker?
      if user.actable_type ="JobSeeker"
         return true
       end
  end

  def is_job_developer?
      if user.actable_type = "JobDeveloper"
         return true
      end
  end
  
  def is_case_manager?
      if user.actable_type = 'CaseManager'
         return true
      end
  end

  def is_agency_admin?
      if user.actable_type = 'Agencyadmin'
         return true
      end
  end
  
  def is_employer?
     
  end
  
  def is_admin?
     
  end

  
=======
   
   def self.is_job_seeker?(user)
     user.actable_type == 'JobSeeker'
   end

   def self.is_job_developer?(user)
      return false unless user.actable_type == "AgencyPerson"
      person = AgencyPerson.find user.actable_id 
      person.agency_roles.each do |ar|
       return true if ar.role == "Job Developer" 
      end
   end
    
   def self.is_case_manager?(user)
      return false unless user.actable_type == "AgencyPerson"
      person = AgencyPerson.find user.actable_id 
      person.agency_roles.each do |ar|
       return true if ar.role == "Case Manager" 
      end
   end
 
    def self.is_agency_admin?(user)
      return false unless user.actable_type == "AgencyPerson"
      person = AgencyPerson.find user.actable_id 
      person.agency_roles.each do |ar|
       return true if ar.role == "Agency Admin" 
      end
    end

    def self.is_agency_manager?(user)
      return false unless user.actable_type == "AgencyPerson"
      person = AgencyPerson.find user.actable_id 
      person.agency_roles.each do |ar|
       return true if ar.role == "Agency Manager" 
      end
    end
    
    def self.is_company_admin?(user)
      return false unless user.actable_type == "CompanyPerson"
      person = CompanyPerson.find user.actable_id 
      person.company_roles.each do |ca|
       return true if ca.role == "Company Admin" 
       end
    end
    
    def self.is_employee?(user)
      return false unless user.actable_type == "CompanyPerson"
      person = CompanyPerson.find user.actable_id 
      person.company_roles.each do |ce|
       return true if ce.role == "Employee" 
      end
    end

>>>>>>> user-auth
end
