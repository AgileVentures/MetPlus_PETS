class AgencyMailerJob < ApplicationJob
  queue_as :default

  def perform(evt_type, job_seeker, *args)
    case evt_type
    when Event::EVT_TYPE[:OTHER_JD_APPLY]
      # args[0] = job_developer
      # args[1] = job_developer
      # args[2] = job
      AgencyMailer.job_applied_by_other_job_developer(job_seeker, args[0],
                                                      args[1],
                                                      args[2]).deliver_later
    end
  end
end
