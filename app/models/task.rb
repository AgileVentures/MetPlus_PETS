class Task < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'target_user_id'

  belongs_to :agency, foreign_key: 'target_agency_id'

  belongs_to :company, foreign_key: 'target_company_id'

  belongs_to :user
  belongs_to :company
  belongs_to :job

  def task_owner
    return owner if owner != nil
    return agency.agency_people_on_role AgencyRole::ROLE[target_agency_role.to_sym] if agency != nil
    return company.people_on_role CompanyRole::ROLE[target_company_role.to_sym] if company != nil
    nil
  end

  def task_owner=(user: nil, agency: {agency: nil, role: nil}, company: {company: nil, role: nil})
    self.owner = user
    self.agency = agency[:agency]
    self.target_agency_role = agency[:role]
    self.company = company[:company]
    self.target_company_role = company[:role]
  end

  def self.find_by_owner_user user
    find_by :owner => user
  end

  def self.find_by_owner_agency agency
    find_by :agency => agency
  end
  def self.find_by_owner_agency_role agency, role
    find_by :agency => agency, :target_agency_role => role
  end
end
