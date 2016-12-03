class AgencyPolicy < ApplicationPolicy
  def update?
    record.nil?  ?  false : user.is_agency_admin?(record)
  end
end
