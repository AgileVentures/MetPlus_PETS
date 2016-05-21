module JobsViewer
  extend ActiveSupport::Concern

  def display_jobs job_type, per_page = 10
    case job_type
      when 'my-company-all'
        return Job.paginate(:page => params[:jobs_page], :per_page => per_page).find_by_company(pets_user.company)
    end
  end

  FIELDS_IN_JOB_TYPE = {
      'my-company-all': [:title, :updated_at, :poster, :num_applicants]
  }

  def job_fields job_type
    FIELDS_IN_JOB_TYPE[job_type.to_sym] || []
  end
end