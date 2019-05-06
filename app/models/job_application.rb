class JobApplication < ApplicationRecord
  belongs_to :job_seeker
  belongs_to :job
  enum status: %i[active accepted not_accepted processing]
  attr_accessor :job_developer
  has_many :status_changes, as: :entity, dependent: :destroy

  has_many :application_questions, inverse_of: :job_application
  has_many :questions, through: :application_questions, dependent: :destroy
  accepts_nested_attributes_for :application_questions, reject_if: :all_blank

  validates_uniqueness_of :job_seeker_id, scope: :job_id
  scope :for_job, ->(job) { joins(:job).where('job_id=?', job.id) }

  scope :active_companies, lambda {
    joins(:job).where(job: Job.find_by_company(Company.active))
  }

  after_create do
    StatusChange.update_status_history(self, :active)
  end

  def status_change_time(status, which = :latest)
    StatusChange.status_change_time(self, status, which)
  end

  def active?
    super && job.status == 'active'
  end

  def processing?
    status == 'processing'
  end

  def accept
    accepted!
    StatusChange.update_status_history(self, :accepted)
    reject_applications = job.job_applications.where.not(status: 1)
    if job.remaining_positions <= 1
      reject_applications.each do |application|
        application.not_accepted!
        StatusChange.update_status_history(application, :not_accepted)
      end
      job.filled
    end
  end

  def reject
    not_accepted!
  end

  def process
    processing!
  end

  def self.find_by_company(company)
    joins(:job).where(job: Job.find_by_company(company))
  end
end
