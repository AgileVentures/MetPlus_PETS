# Job application policy
class JobApplicationPolicy < ApplicationPolicy
  def accept?
    correct_company_person? user
  end

  def reject?
    correct_company_person? user
  end

  def process_application?
    correct_company_person? user
  end

  def show?
    correct_company_person? user
  end

  private

  def correct_company_person?(user)
    User.is_company_person?(user) && record.job.company == user.company
  end
end
