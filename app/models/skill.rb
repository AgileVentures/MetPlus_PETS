class Skill < ActiveRecord::Base

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false

  validates_presence_of :description

  has_many :job_skills, dependent: :destroy
  
  has_many :jobs, through: :job_skills
end
