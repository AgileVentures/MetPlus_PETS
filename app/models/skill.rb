class Skill < ActiveRecord::Base

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false
  
  validates_presence_of :description

  has_and_belongs_to_many :job_categories
  has_many :job_skills
  has_many :jobs, through: :job_skills
end
