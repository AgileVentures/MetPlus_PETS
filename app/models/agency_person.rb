class AgencyPerson < ActiveRecord::Base
	
  acts_as     :user 
  belongs_to  :address
  belongs_to  :agency
  has_many    :job_specialities
  has_many    :job_categories, 
              :through => :job_specialities
  has_and_belongs_to_many :job_seekers
  has_and_belongs_to_many :agency_roles

  
end
