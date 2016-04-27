class JobPolicy < ApplicationPolicy
  def apply?
    user.is_job_seeker? ||
        (user.is_a?(AgencyPerson) &&
            (user.is_job_developer?(user.agency) ||
            user.is_case_manager?(user.agency)))
  end
end
