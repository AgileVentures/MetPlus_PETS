require_relative '../job_applications'
module JobApplications
  class Hire
    def call(job_application)
      raise JobNotActive, '' unless job_application.active? || job_application.processing?

      job_application.accept
      decrease_remaining_positions(job_application.job)

      send_notification(job_application)
      close_all_tasks(job_application)
    end

    private

    def send_notification(job_application)
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_ACCEPTED, job_application) if job_developer
    end

    def close_all_tasks(job_application)
      JobApplication.for_job(job_application.job).each do |current_job_application|
        task = Task.job_application_target(current_job_application)
        task.first.force_close if task.count == 1
      end
    end

    def decrease_remaining_positions(job)
      remaining_positions = job.remaining_positions - 1
      job.update_attributes(remaining_positions: remaining_positions)
    end
  end
end
