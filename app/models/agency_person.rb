class AgencyPerson < ActiveRecord::Base
  acts_as :user 
  has_many :job_specialities
  has_many :job_categories, :through => :job_specialities
  belongs_to :address
  belongs_to :agency
  has_and_belongs_to_many :job_seekers
  has_and_belongs_to_many :agency_roles

  
end
