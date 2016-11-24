module JobsViewer
  extend ActiveSupport::Concern

  def self.included(m)
    return unless m < ActionController::Base
    m.helper_method :job_fields
  end

  def display_jobs(job_type, per_page = 10)
    case job_type
    when 'my-company-all'
      collection = Job.order(:title).find_by_company(pets_user.company)
    when 'recent-jobs'
      collection = Job.new_jobs(Time.now - 3.weeks).order(created_at: :desc)
    end
    return collection if collection.nil?
    collection.paginate(page: params[:job_page], per_page: per_page)
  end

  FIELDS_IN_JOB_TYPE = {
    'my-company-all': [:title, :status, :poster, :num_applicants, :updated_at],
    'recent-jobs': [:title, :company, :description, :posted]
  }.freeze

  def job_fields(job_type)
    FIELDS_IN_JOB_TYPE[job_type.to_sym] || []
  end
end
