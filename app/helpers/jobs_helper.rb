module JobsHelper
  def list_jobs
    @jobs ||= Job.take(20)
  end
end
