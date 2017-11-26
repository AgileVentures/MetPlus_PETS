class AssignAgencyPersonToJobSeeker
  def call(all_job_seekers, role, agency_person, is_self_assign = true)
    all_job_seekers = [all_job_seekers] unless all_job_seekers.respond_to?('each')
    all_job_seekers.each do |job_seeker|
      case role
      when :JD
        assign_job_developer_to_job_seeker(job_seeker, agency_person, is_self_assign)
      when :CM
        assign_case_manager_to_job_seeker(job_seeker, agency_person, is_self_assign)
      else
        raise InvalidRole, ''
      end
    end
  end

  class NotAJobDeveloper < StandardError
  end
  class NotACaseManager < StandardError
  end
  class InvalidRole < StandardError
  end

  private

  def assign_job_developer_to_job_seeker(job_seeker, job_developer, is_self_assign)
    obj = Struct.new(:job_seeker, :agency_person)

    raise NotAJobDeveloper, '' unless job_developer.is_job_developer? job_developer.agency
    job_seeker.assign_job_developer job_developer, job_developer.agency
    if is_self_assign
      Event.create(:JD_SELF_ASSIGN_JS, obj.new(job_seeker, job_developer))
    else
      Event.create(:JD_ASSIGNED_JS, obj.new(job_seeker, job_developer))
    end
    Task.find_by_type_and_target_job_seeker_open('need_job_developer', job_seeker)
              .each do |task|
      task.force_close
      task.save!
    end
  end

  def assign_case_manager_to_job_seeker(job_seeker, case_manager, is_self_assign)
    obj = Struct.new(:job_seeker, :agency_person)

    raise NotACaseManager, '' unless case_manager.is_case_manager? case_manager.agency
    job_seeker.assign_case_manager case_manager, case_manager.agency
    if is_self_assign
      Event.create(:CM_SELF_ASSIGN_JS, obj.new(job_seeker, case_manager))
    else
      Event.create(:CM_ASSIGNED_JS, obj.new(job_seeker, case_manager))
    end
  end
end
