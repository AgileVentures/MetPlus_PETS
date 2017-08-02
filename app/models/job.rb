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

  has_many   :required_skills, -> { where job_skills: { required: true } },
             through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :nice_to_have_skills, -> { where job_skills: { required: false } },
             through: :job_skills, class_name: 'Skill', source: :skill
  has_many   :job_applications
  has_many   :job_seekers, through: :job_applications

  SHIFT_OPTIONS = %w(Morning Day Evening).freeze
  YEARS_OF_EXPERIENCE_OPTIONS = (0..20).to_a.freeze
  validates_presence_of :title
  validates_presence_of :company_job_id
  validates_presence_of :fulltime, allow_blank: true
  validates_inclusion_of :shift, in: SHIFT_OPTIONS,
                                 message: "must be one of: #{SHIFT_OPTIONS.join(', ')}"
  validates_length_of   :title, maximum: 100
  validates_presence_of :description
  validates_length_of   :description, maximum: 10_000
  validates_presence_of :company_id
  validates_presence_of :company_person_id, allow_nil: true
  validates_numericality_of :years_of_experience,
                            allow_blank: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 20
  scope :new_jobs, ->(given_time) { where('created_at > ?', given_time) }
  scope :find_by_company, ->(company) { where(company: company) }

  enum status: [:active, :filled, :revoked]
  has_many :status_changes, as: :entity, dependent: :destroy

  # `status.to_sym` is necessary because sometimes we would need to create
  #  a job with a status other than `active`(in tests) and we do not want
  #  to have a mismatch in statuses across `jobs` and `status_changes` tables.

  after_create do
    StatusChange.update_status_history(self, status.to_sym || :active)
  end

  def number_applicants
    job_applications.size
  end

  def apply(job_seeker)
    job_application = job_applications.build(job_seeker_id: job_seeker.id)
    if job_application.save!
      # Send mail to the company with the attached resume
      CompanyMailerJob.set(wait: Event.delay_seconds.seconds)
                      .perform_later(Event::EVT_TYPE[:JS_APPLY],
                                     company,
                                     nil,
                                     application: job_application,
                                     resume_id: job_seeker.resumes[0].id)
      yield(job_application, self, job_seeker) if block_given?
      job_application
    end
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

  def recent_for?(user)
    created_at > user.last_sign_in_at
  end

  private

  def save_job_to_cruncher
    cruncher_posted = true

    unless (changed & %w(title description)).empty?
      begin
        if id_changed?
          cruncher_posted = JobCruncher.create_job(id, title, description)
          # If we fail on create it may be because the cruncher DB and
          # front-end DB are out of sync (which will almost certainly be
          # the case when the front-end is in testing).
          # In that case, try to update the job instead.
          unless cruncher_posted
            cruncher_posted = JobCruncher.update_job(id, title, description)
          end
        else
          cruncher_posted = JobCruncher.update_job(id, title, description)
        end
      rescue
        # Exception occured and save/update TX has been rolled back
        cruncher_posted = false
      end
    end
    unless cruncher_posted
      errors.add(:job, 'could not be posted to Cruncher, please try again.')

      # Here raising ActiveRecord::RecordInvalid in order to
      # 1) force a rollback of the save (update) transaction (if not already),
      # and, 2) force a return value of 'false' from save (update)
      # See: http://tech.taskrabbit.com/blog/2013/05/23/rollback-after-save/

      raise ActiveRecord::RecordInvalid, self
    end
    true
  end
end
