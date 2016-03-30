class Task < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'

  belongs_to :owner_agency, class_name: 'Agency', foreign_key: 'owner_agency_id'

  belongs_to :owner_company, class_name: 'Company', foreign_key: 'owner_company_id'

  belongs_to :user
  belongs_to :company
  belongs_to :job

  validates_with TaskOwnerValidator

  def task_owner
    return owner.pets_user if owner != nil
    return owner_agency.agency_people_on_role AgencyRole::ROLE[owner_agency_role.to_sym] if owner_agency != nil and owner_agency_role != nil
    return owner_company.people_on_role CompanyRole::ROLE[owner_company_role.to_sym] if owner_company != nil and owner_company_role != nil
    nil
  end

  def task_owner=(user: nil, agency: {agency: nil, role: nil}, company: {company: nil, role: nil})
    self.owner = nil
    self.owner = user.user if user != nil
    self.owner_agency = agency[:agency]
    self.owner_agency_role = agency[:role]
    self.owner_company = company[:company]
    self.owner_company_role = company[:role]
  end

  def self.find_by_owner_user user
    return where("owner_user_id=? and (deferred_date IS NULL or deferred_date < ?)",
                  user.user.id, Date.today) \
                if user.is_a? JobSeeker
    return where("(owner_user_id=? or (owner_agency_id=? and owner_agency_role in (?))) and (deferred_date IS NULL or deferred_date < ?)",
                 user.user.id, user.agency.id, user.agency_roles.pluck(:role).collect{|pa| AgencyRole::ROLE.key(pa)},
                 Date.today) \
                   if user.is_a? AgencyPerson
    return where("(owner_user_id=? or (owner_company_id=? and owner_company_role in (?))) and (deferred_date IS NULL or deferred_date < ?)",
                 user.user.id, user.company.id, user.company_roles.pluck(:role).collect{|pa| CompanyRole::ROLE.key(pa)},
                 Date.today) \
                   if user.is_a? CompanyPerson
  end



  def user
    return nil if user.is_nil?
    user.pets_user
  end

  def user= user
    self.user = user.user
  end
end
