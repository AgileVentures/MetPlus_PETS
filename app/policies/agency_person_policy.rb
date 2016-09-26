class AgencyPersonPolicy < ApplicationPolicy
  def update?
    user.is_agency_admin? record.agency
  end

  def destroy?
    update?
  end

  def home?
    user.is_agency_person? record.agency
  end

  def show?
    user.is_agency_person? record.agency
  end

  def assign_job_seeker?
    user.is_agency_person? record.agency
  end

  def list_js_cm?
    user.is_agency_person? record.agency
  end

  def list_js_jd?
    list_js_cm?
  end

  def list_js_without_jd?
    user.is_agency_person? record.agency
  end

  def list_js_without_cm?
    list_js_without_jd?
  end

  def update_profile?
    user.is_agency_person? record.agency and user == record
  end

  def edit_profile?
    update_profile?
  end

end
