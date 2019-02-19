class TaskPolicy < ApplicationPolicy
  def in_progress?
    record.task_owner == user
  end

  def done?
    record.task_owner == user
  end

  def assign?
    if record.task_owner.is_a? Array
      record.task_owner.include? user
    else
      record.task_owner == user
    end
  end

  def tasks?
    return false if user.nil?
    return false if user.job_seeker?

    true
  end

  def index?
    return false if user.nil?
    return false if user.job_seeker?

    true
  end

  def list_owners?
    return false if user.nil?
    return true if !record.owner_agency.nil? && user.agency_admin?(record.owner_agency)
    return true if !record.owner_company.nil? && user.company_admin?(record.owner_company)

    false
  end
end
