require_relative '../job_applications'
module JobApplications
  class Hire
    def call(job_application)
      raise JobNotActive, '' if !job_application.active? && !job_application.processing?
      job_application.accept
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_ACCEPTED, job_application) if job_developer
    end
  end
end