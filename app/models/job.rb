class Job < ActiveRecord::Base

  validates :employer, :presence => true
  validates :company, :presence => true
  validates :title, length: {in: 1..150},
                    :presence => true
  validates :description, :presence => true,
                          length: {minimum: 20}

  belongs_to :employer
  belongs_to :company

  has_many :job_skills
  has_many :skills, :through => :job_skills

  has_many :required_skills, -> { where job_skills: { required: true } }, through: :job_skills, class_name: 'Skill', source: :skill
  has_many :nice_to_have_skills, -> { where job_skills: { required: false } }, through: :job_skills, class_name: 'Skill', source: :skill
end
