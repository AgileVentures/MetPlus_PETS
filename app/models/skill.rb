class Skill < ActiveRecord::Base
  has_many :job_skills
  has_many :jobs, :through => :job_skills

  validates :name, :presence => true,
                   length: {in: 1..100}
  validates :description, :presence => true,
                          length: {in: 1..500}
end
