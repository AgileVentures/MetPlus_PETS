module JobApplications
  class Reject
    def call(job_application, reason)
      raise JobNotActive, '' if !job_application.active? && !job_application.processing?
      job_application.reason_for_rejection = reason
      job_application.save
      job_application.reject
      
      send_notification(job_application)
    end

    private

    def send_notification(job_application)
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_REJECTED, job_application) if job_developer
    end
  end
end