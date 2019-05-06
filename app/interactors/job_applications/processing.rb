require_relative '../job_applications'
module JobApplications
  class Processing
    def call(job_application, company_person)
      raise JobNotActive, 'Job is not active' unless job_application.active?

      job_application.process
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_PROCESSING, job_application) if job_developer
      assign_task_to_company_person(job_application, company_person)
    end

    private

    def assign_task_to_company_person(job_application, company_person)
      tasks = Task.find_by_type_and_target_job_application_open(
        :job_application,
        job_application
      )
      return unless tasks.count == 1

      task = tasks.first
      task.force_assign(company_person) if task.status == Task::STATUS[:ASSIGNED]
      task.assign(company_person) if task.status == Task::STATUS[:NEW]
    end
  end
end
