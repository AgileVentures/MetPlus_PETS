class JobCategory < ApplicationRecord
  has_and_belongs_to_many :agency_people, join_table: 'job_specialities'
  has_many :jobs
  has_and_belongs_to_many :skills

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false

  validates_presence_of :description
end
