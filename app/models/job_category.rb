class JobCategory < ActiveRecord::Base
 has_many :job_specialities
 has_many :agency_poeple, through: :job_specialities
 has_many :jobs
 has_and_belongs_to_many:skills

 validates_presence_of :name
 validates_presence_of :description

end
