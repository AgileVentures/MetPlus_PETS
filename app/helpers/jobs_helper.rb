module JobsHelper
  def list_jobs
    @jobs ||= Job.all
  end
end
