class TaskOwnerValidator < ActiveModel::Validator
  def validate(task)
    if task.try(:owner).nil? and task.try(:owner_company).nil? and task.try(:owner_agency).nil?
      task.errors[:task_owner] << "need to be set"
    elsif not task.owner_company.nil? and task.try(:owner_company_role).nil?
      task.errors[:task_owner] << "no company role set"
    elsif not task.owner_company.nil? and not CompanyRole::ROLE.keys.include?(task.try(:owner_company_role).to_sym)
      task.errors[:task_owner] << "unknown company role"
    elsif not task.owner_agency.nil? and task.try(:owner_agency_role).nil?
      task.errors[:task_owner] << "no agency role set"
    elsif not task.owner_agency.nil? and not AgencyRole::ROLE.keys.include?(task.try(:owner_agency_role).to_sym)
      task.errors[:task_owner] << "unknown agency role"
    end
  end
end
