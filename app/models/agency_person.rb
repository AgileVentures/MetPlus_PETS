class AgencyPerson < ActiveRecord::Base
  belongs_to :address
  belongs_to :agency
  has_and_belongs_to_many :jobseekers, class_name: "JobSeeker"
end
