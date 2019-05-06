class AgencyPersonPolicy < ApplicationPolicy
  def update?
    user.agency_admin? record.agency
  end

  def destroy?
    update?
  end

  def home?
    user.agency_person? record.agency
  end

  def show?
    user.agency_person? record.agency
  end

  def assign_job_seeker?
    user.agency_person? record.agency
  end

  def list_js_cm?
    user.agency_person? record.agency
  end

  def list_js_jd?
    list_js_cm?
  end

  def list_js_without_jd?
    user.agency_person? record.agency
  end

  def list_js_without_cm?
    list_js_without_jd?
  end

  def update_profile?
    user.agency_person?(record.agency) && user == record
  end

  def edit_profile?
    update_profile?
  end

  def my_profile?
    user.agency_person? record.agency
  end
end
