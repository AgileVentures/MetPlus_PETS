class TaskPolicy < ApplicationPolicy
  def in_progress?
    record.task_owner == user
  end
  def done?
    record.task_owner == user
  end
  def assign?
    record.task_owner.include? user
  end
  def tasks?
    not user.nil?
  end
end
