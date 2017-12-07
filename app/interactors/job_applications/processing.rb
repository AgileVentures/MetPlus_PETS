module JobApplications
  class Processing
    def call(job_application)
      raise JobNotActive, "Job is not active" unless job_application.active?
      job_application.process
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_PROCESSING, job_application) if job_developer
    end
  end

  class JobNotActive < StandardError
  end
end