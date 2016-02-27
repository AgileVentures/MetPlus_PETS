module JobsHelper
  def list_jobs
    @jobs ||= Job.limit(25).includes(:company)
  end
end
