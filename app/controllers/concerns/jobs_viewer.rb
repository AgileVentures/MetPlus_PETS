module JobsViewer
  extend ActiveSupport::Concern

  def self.included(m)
    return unless m < ActionController::Base

    m.helper_method :job_fields
  end

  def display_jobs(job_type)
    case job_type
    when 'my-company-all'
      Job.order(:title).find_by_company(pets_user.company)
    when 'recent-jobs'
      Job.new_jobs(Time.now - 3.weeks).order(created_at: :desc)
    end
  end

  FIELDS_IN_JOB_TYPE = {
    'my-company-all' => [:title, :status, :poster, :num_applicants, :updated_at],
    'recent-jobs' => [:title, :company, :description, :posted]
  }.freeze

  def job_fields(job_type)
    FIELDS_IN_JOB_TYPE[job_type] || []
  end
end
