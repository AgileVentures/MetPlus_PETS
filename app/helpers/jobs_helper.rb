module JobsHelper
  def list_jobs
    @jobs ||= Job.take(25)
  end
  
  def sort_instruction(count)
    return ' Click on any column title to sort.' if count > 1
  end
end
