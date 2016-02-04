class Job < ActiveRecord::Base
  belongs_to :company
  belongs_to :company_person
  has_one    :address, as: :location
  belongs_to :job_category
  has_many   :job_skills
  has_many   :skills, through: :job_skills
  has_many   :required_skills, -> {where job_skills: {required: true}},
                through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :nice_to_have_skills, -> {where job_skills: {required: false}},
                through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :skill_levels, through: :job_skills

  CONTENT_TYPES = ['morning', 'day', 'evening']
  validates_presence_of :title
  validates_presence_of :jobId 
  validates_inclusion_of :shift, :in => CONTENT_TYPES,
  :message => "must be one of: #{CONTENT_TYPES.join(', ')}"
  validates_length_of   :title, maximum: 100
  validates_presence_of :description
  validates_length_of   :description, maximum: 10000

  # validates_presence_of :company_id
  # validates_presence_of :job_category_id
  # validates_presence_of :company_person_id
end
