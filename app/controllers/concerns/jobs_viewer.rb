module JobsViewer
  extend ActiveSupport::Concern

  def display_jobs job_type, per_page = 10
    case job_type
      when 'my-company-all'
        return Job.order(:title).
            paginate(:page => params[:jobs_page], :per_page => per_page).
            find_by_company(pets_user.company)
      when 'recent-jobs'
        return Job.new_jobs(Time.now - 3.weeks).order(created_at: :desc).
            paginate(:page => params[:js_home_page], :per_page => per_page)
    end
  end

  FIELDS_IN_JOB_TYPE = {
      'my-company-all': [:title, :status, :poster, :num_applicants, :updated_at]
  }

  def job_fields job_type
    FIELDS_IN_JOB_TYPE[job_type.to_sym] || []
  end
end
