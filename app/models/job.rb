class Job < ActiveRecord::Base
  after_save :save_job_to_cruncher
  belongs_to :company
  belongs_to :company_person
  belongs_to :address
  belongs_to :job_category

  has_many   :job_skills, inverse_of: :job, dependent: :destroy
  has_many   :skills, through: :job_skills
  accepts_nested_attributes_for :job_skills, allow_destroy: true,
                                reject_if: :all_blank

  has_many   :required_skills, -> {where job_skills: {required: true}},
                through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :nice_to_have_skills, -> {where job_skills: {required: false}},
                through: :job_skills, class_name: 'Skill', source: :skill
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
  scope :new_jobs, ->(given_time) {where("created_at > ?", given_time)}
  scope :find_by_company, ->(company) {where(:company => company)}

  enum status: [:active, :filled, :revoked]
  has_many :status_changes, as: :entity, dependent: :destroy

  after_create do
    StatusChange.update_status_history(self, :active)
  end

  def number_applicants
    job_applications.size
  end

  def apply job_seeker
    job_seekers << job_seeker
    save!

    # Download resume from the Cruncher
    resume_id = job_seeker.resumes[0].id
    temp_file = ResumeCruncher.download_resume(resume_id)
    job_application = last_application_by_job_seeker(job_seeker)

    # Send mail to the company with the attached resume
    CompanyMailerJob.set(wait: Event.delay_seconds.seconds).
                     perform_later(Event::EVT_TYPE[:JS_APPLY],
                     self.company,
                      nil, { application: job_application,
                      resume_file_path: temp_file.path })

    # Remove the temp file
    temp_file.unlink

  end

  def status_change_time(status, which = :latest)
    StatusChange.status_change_time(self, status, which)
  end

  def filled
    update_attribute(:status, :filled)
    StatusChange.update_status_history(self, :filled)
  end

  def revoked
    if update_attribute(:status, :revoked)
      StatusChange.update_status_history(self, :revoked)
      return true
    end
    false
  end

  def last_application_by_job_seeker(job_seeker)
    job_applications.where(job_seeker: job_seeker).order(:created_at).last
  end


  def save_job_to_cruncher()
      begin
        if self.id_changed?
          return true if JobCruncher.create_job(id, title, description)
        end

      rescue
        errors.add(:job, 'could not be created in Cruncher, please try again.')
        raise ActiveRecord::RecordInvalid.new(self)
      end
  end
end
