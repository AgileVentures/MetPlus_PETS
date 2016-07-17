class JobApplication < ActiveRecord::Base
  belongs_to :job_seeker
  belongs_to :job
  enum status: [:active, :accepted, :not_accepted]

  def status_name
    status.to_s.camelcase
  end
end
