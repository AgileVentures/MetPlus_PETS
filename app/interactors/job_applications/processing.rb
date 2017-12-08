module JobApplications
  class Processing
    def call(job_application, company_person)
      raise JobNotActive, 'Job is not active' unless job_application.active?
      job_application.process
      job_developer = job_application.job_seeker.job_developer
      Event.create(:APP_PROCESSING, job_application) if job_developer

      task = Task.find_by_type_and_target_job_application_open(
        :job_application,
        job_application
      )
      task.first.assign(company_person) if task.count == 1
    end
  end

  class JobNotActive < StandardError
  end
end
