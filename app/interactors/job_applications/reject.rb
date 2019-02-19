require_relative '../job_applications'
module JobApplications
  class Reject
    def call(job_application, reason)
      raise JobNotActive, '' unless job_application.active? || job_application.processing?

      job_application.reason_for_rejection = reason
      job_application.save
      job_application.reject

      send_notification(job_application)

      close_task(job_application)
    end

    private

    def send_notification(job_application)
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_REJECTED, job_application) if job_developer
    end

    def close_task(job_application)
      task = Task.job_application_target(job_application)
      task.first.force_close if task.count == 1
    end
  end
end
