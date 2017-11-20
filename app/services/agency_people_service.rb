
class AgencyPeopleService 
  def assign_to_job_seeker job_seeker, role, agency_person
    obj = Struct.new(:job_seeker, :agency_person)
    
    case role
    when :JD
      raise NotAJobDeveloper.new unless agency_person.is_job_developer? agency_person.agency
      job_seeker.assign_job_developer agency_person, agency_person.agency
      Event.create(:JD_SELF_ASSIGN_JS, obj.new(job_seeker, agency_person))
    when :CM
      raise NotACaseManager.new unless agency_person.is_case_manager? agency_person.agency
      job_seeker.assign_case_manager agency_person, agency_person.agency
      Event.create(:CM_SELF_ASSIGN_JS, obj.new(@job_seeker, @agency_person))      
    else
      raise InvalidRole.new
    end
  end

  class NotAJobDeveloper < StandardError
  end
  class NotACaseManager < StandardError
  end
  class InvalidRole < StandardError
  end
end