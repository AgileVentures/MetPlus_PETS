class TaskPolicy < ApplicationPolicy
  def in_progress?
    record.task_owner == user
  end
  def done?
    record.task_owner == user
  end
end
