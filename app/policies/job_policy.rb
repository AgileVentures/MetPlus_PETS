class JobPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.is_a?(CompanyPerson)
        scope.where(company_id: user.company)
      else
        scope
      end
    end
  end

  def new?
    User.is_job_developer?(user) || User.is_agency_admin?(user) ||
      user.is_a?(CompanyPerson)
  end

  def create?
    edit?
  end

  def edit?
    User.is_job_developer?(user) || User.is_agency_admin?(user) ||
      correct_company_person?
  end

  def update?
    edit?
  end

  def match_job_seekers?
    edit?
  end

  def destroy?
    correct_company_person?
  end

  def show?
    user.nil? || user.is_a?(JobSeeker) || User.is_job_developer?(user) ||
      User.is_agency_admin?(user) || correct_company_person?
  end

  def apply?
    record.active?
  end

  def revoke?
    User.is_job_developer?(user) || correct_company_person?
  end

  def notify_job_developer?
    record.company.company_people.include? user
  end

  private

  def correct_company_person?
    user.is_a?(CompanyPerson) && (record.company == user.company)
  end
end
