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
      self.role == 'job_seeker'
  end

  def is_job_developer?
      self.role == 'job_developer'
  end
  
  def is_case_manager?
      self.role == 'case_manager'
  end

  def is_agency_admin?
      self.role == 'agency_admin'
  end
  
  def is_employer?
      self.role == 'employer'
  end
  
  def is_admin?
      self.role == 'admin'
  end

  
end
