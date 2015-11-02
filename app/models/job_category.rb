class JobCategory < ActiveRecord::Base
 has_and_belongs_to_many :agencypeople, class_name: "AgencyPerson",join_table => job_specialities
 has_many :jobs
 has_and_belongs_to_many:skills

 validates_presence_of :name
 validates_presence_of :description

end
