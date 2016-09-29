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
    return false if user.is_job_seeker?
    true
  end

  def index?
    return false if user.nil?
    return false if user.is_job_seeker?
    true
  end
end
