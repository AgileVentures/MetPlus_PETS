module AgencyPeople
  class AssignNewJobSeekers
    def initialize
      @assign_agency_person = JobSeekers::AssignAgencyPerson.new
    end

    def call(all_job_seekers, role, agency_person)
      assign_new_job_seekers(all_job_seekers, role, agency_person)

      remove_job_seekers(all_job_seekers, role, agency_person)
    end

    private

    def current_job_seekers(agency_person, role)
      case role
      when :JD
        AgencyPerson.find(agency_person.id).job_seekers_as_job_developer
      when :CM
        AgencyPerson.find(agency_person.id).job_seekers_as_case_manager
      end
    end

    def remove_job_seekers(all_job_seekers, role, agency_person)
      delete_job_seekers = current_job_seekers(agency_person, role) - all_job_seekers
      AgencyRelation.where(
        job_seeker: delete_job_seekers,
        agency_person: agency_person,
        agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[role])
      ).delete_all
    end

    def assign_new_job_seekers(all_job_seekers, role, agency_person)
      current_job_seekers = current_job_seekers(agency_person, role)

      all_job_seekers.each do |job_seeker|
        unless current_job_seekers.include?(job_seeker)
          @assign_agency_person.call(job_seeker, role, agency_person, false)
        end
      end
    end
  end
end
