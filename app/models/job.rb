class Job < ActiveRecord::Base
  belongs_to :company
  belongs_to :company_person
  belongs_to :address
  belongs_to :job_category
  has_many   :job_skills
  has_many   :skills, through: :job_skills
  has_many   :required_skills, -> {where job_skills: {required: true}},
                through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :nice_to_have_skills, -> {where job_skills: {required: false}},
                through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :skill_levels, through: :job_skills
  has_many   :job_applications
  has_many   :job_seekers, through: :job_applications

  SHIFT_OPTIONS = ['Morning', 'Day', 'Evening']
  validates_presence_of :title
  validates_presence_of :company_job_id
  validates_presence_of :fulltime, allow_blank: true
  validates_inclusion_of :shift, :in => SHIFT_OPTIONS,
  :message => "must be one of: #{SHIFT_OPTIONS.join(', ')}"
  validates_length_of   :title, maximum: 100
  validates_presence_of :description
  validates_length_of   :description, maximum: 10000
  validates_presence_of :company_id
  validates_presence_of :company_person_id, allow_nil: true
  #validates_presence_of :job_category_id
  scope :new_jobs, ->(given_time) {where("created_at > ?", given_time)}
  scope :find_by_company, ->(company) {where(:company => company)}

  def number_applicants
    job_applications.size
  end

  def apply job_seeker
    job_seekers << job_seeker
    save!
  end

  def last_application_by_job_seeker(job_seeker)
    job_applications.where(job_seeker: job_seeker).order(:created_at).last
  end
  
  def save!
      return false if not super
      begin
        return true if JobCruncher.create_job(id, title, description)
      rescue 
        errors.add(:job, 'could not be created -please try again')
        destroy
        raise
      end
      false
  end
end
