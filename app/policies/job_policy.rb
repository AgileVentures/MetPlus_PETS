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

  def allow_js_apply?
    # view
    record.active? && user.is_a?(JobSeeker)
  end

  def allow_jd_apply?
    # view
    record.active? && User.is_job_developer?(user)
  end

  def revoke?
    User.is_job_developer?(user) || correct_company_person?
  end

  def list?
    User.is_a?(CompanyPerson) || User.is_a?(JobSeeker)
  end

  def permitted_attributes
    if user.is_a?(CompanyPerson)
      [ :description,
        :shift, 
        :company_job_id, 
        :fulltime,
        :title,
        :address_id,
        job_skills_attributes: [:id, :_destroy, :skill_id,
                                :required, :min_years, :max_years]
      ]
    elsif User.is_job_developer?(user) || User.is_agency_admin?(user)
      [ :description,
        :shift, 
        :company_job_id, 
        :fulltime,
        :company_id,
        :title,
        :address_id,
        :company_person_id,
        job_skills_attributes: [:id, :_destroy, :skill_id,
                                :required, :min_years, :max_years]
      ]
    end
  end

  private

  def correct_company_person?
    user.is_a?(CompanyPerson) && (record.company == user.company)
  end
end
