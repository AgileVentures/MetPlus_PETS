class Skill < ApplicationRecord
  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false

  validates_presence_of :description

  has_many :job_skills
  has_many :jobs, through: :job_skills, dependent: :destroy

  belongs_to :organization, polymorphic: true

  def has_job?
    jobs.any?
  end
end
