class JobPolicy < ApplicationPolicy
  def apply?
    not user.nil? and
      (user.is_job_seeker? or
          (user.is_a?(AgencyPerson) and
              (user.is_job_developer?(user.agency) or
              user.is_case_manager?(user.agency))))
  end
end
