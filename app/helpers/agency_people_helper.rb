module AgencyPeopleHelper
  def disable_agency_admin?(agency_person, role)
    # Disable the check_box for the agency admin role if this person
    # is the sole admin for the agency (return true to disable).

    return false unless role == AgencyRole::ROLE[:AA]

    agency_person.sole_agency_admin?
  end

  def job_seekers_assigned_or_assignable_to_ap(agency_person, role_key)
    # Inputs:
    #  agency_person: AgencyPerson instance
    #  role_key:      key for AgencyPersonRole::ROLE hash (e.g. :JD, :CM, etc.)

    # Returns a sorted (last_name) array of job seekers that are:
    #   1) Unassigned to any agency_person in the given role, or,
    #   2) Are already assigned to this agency_person in this role

    # NOTE: this logic assumes *one* agency in the system - will need
    # refactoring if we extend to multiple agencies per instance

    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[role_key]).id

    seekers_with_role = JobSeeker.joins(:agency_relations)
                                 .where('agency_relations.agency_role_id = ?', role_id)

    seekers = JobSeeker.where.not(id: seekers_with_role)

    seekers += seekers_with_role.joins(:agency_relations)
                                .where('agency_relations.agency_person_id = ?',
                                       agency_person.id)

    seekers.sort_by(&:last_name)
  end

  def job_seekers_assigned_for_role(agency_person, role_key)
    # Inputs:
    #  agency_person: AgencyPerson instance
    #  role_key:      key for AgencyPersonRole::ROLE hash (e.g. :JD, :CM, etc.)

    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[role_key]).id

    JobSeeker.joins(:agency_relations)
             .where(agency_relations: { agency_role_id: role_id,
                                        agency_person_id: agency_person.id })
  end
end
