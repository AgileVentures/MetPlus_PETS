class JobApplication < ActiveRecord::Base
  belongs_to :job_seeker
  belongs_to :job
  enum status: [:active, :accepted, :not_accepted]

  has_many :status_changes, as: :entity, dependent: :destroy

  def status_name
    status.to_s.camelcase
  end

  def active?
    super && job.status == 'active'
  end

  def accept
    accepted!
		reject_applications = job.job_applications.where.not(id: self.id)
		reject_applications.each do |application|
			application.not_accepted!
		end
    job.filled
  end

end
