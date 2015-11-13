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

  
end
