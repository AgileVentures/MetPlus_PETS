module JobsHelper
  def list_jobs
    @jobs ||= Job.take(25)
  end
end
