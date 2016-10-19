class JobApplication < ActiveRecord::Base
  belongs_to :job_seeker
  belongs_to :job
  enum status: [:active, :accepted, :not_accepted]
  attr_accessor :reason_for_rejection

  has_many :status_changes, as: :entity, dependent: :destroy

  validates_uniqueness_of :job_seeker_id, scope: :job_id

  after_create do
    StatusChange.update_status_history(self, :active)
  end

  def status_change_time(status, which = :latest)
    StatusChange.status_change_time(self, status, which)
  end

  def active?
    super && job.status == 'active'
  end

  def accept
    accepted!
    StatusChange.update_status_history(self, :accepted)
		reject_applications = job.job_applications.where.not(id: self.id)
		reject_applications.each do |application|
			application.not_accepted!
      StatusChange.update_status_history(application, :not_accepted)
		end
    job.filled
  end

  def reject
    not_accepted!
  end

end
