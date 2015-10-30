class AgencyPerson < ActiveRecord::Base
  acts_as :user, validates_actable: false
  
  belongs_to :agency
  belongs_to :address
  has_and_belongs_to_many :agency_roles
  # has_many :job_specialities
  has_many :job_categories, join_table: :job_specialities
  
  validates_presence_of :agency_id
end
