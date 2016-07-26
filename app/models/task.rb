class Task < ActiveRecord::Base

  include TaskManager::TaskManager
  include TaskManager::BusinessLogic

  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'

  belongs_to :owner_agency, class_name: 'Agency', foreign_key: 'owner_agency_id'

  belongs_to :owner_company, class_name: 'Company', foreign_key: 'owner_company_id'

  belongs_to :user
  belongs_to :company
  belongs_to :job

  validates_with TaskOwnerValidator

  scope :today_tasks, -> {where('deferred_date IS NULL or deferred_date < ?', Date.today + 1)}
  scope :open_tasks, -> {today_tasks.where('status != ?', STATUS[:DONE])}
  scope :closed_tasks, -> {where('status = ?', STATUS[:DONE])}
  scope :user_tasks, -> (user) {where('owner_user_id=?', user.user.id)}
  scope :agency_tasks, -> (user) {where('owner_agency_id = ? or owner_user_id in (?)',  
                          user.agency.id, user.agency.agency_people.map{|a| a.acting_as.id}.collect)}
  scope :company_tasks, -> (user) {where('owner_company_id = ? or owner_user_id in (?)',  
                          user.company.id, user.company.company_people.map{|a| a.acting_as.id}.collect)}

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
    today_tasks.user_tasks(user)
  end

  def self.find_by_owner_user_open user
    open_tasks.user_tasks(user)
  end

  def self.find_by_owner_user_closed user
    closed_tasks.user_tasks(user)
  end

  def self.find_by_agency user
    today_tasks.agency_tasks(user)
  end

  def self.find_by_agency_open user
    open_tasks.agency_tasks(user)
  end

  def self.find_by_agency_closed user
    closed_tasks.agency_tasks(user)
  end

  def self.find_by_company user
    today_tasks.company_tasks(user)
  end
  
  def self.find_by_company_open user
    open_tasks.company_tasks(user)
  end

  def self.find_by_company_closed user
    closed_tasks.company_tasks(user)
  end
  

  def target
    return person unless person.nil?
    return company unless company.nil?
    return job unless job.nil?
    nil
  end

  def target= target
    case target
      when User, AgencyPerson, CompanyPerson, JobSeeker
        self.person = target.pets_user.user
        self.company = nil
        self.job = nil
      when Job
        self.person = nil
        self.company = nil
        self.job = target
      when Company
        self.person = nil
        self.company = target
        self.job = nil
    end
  end

  def person
    return nil if self.user.nil?
    self.user.pets_user
  end

  def person= person
    self.user = nil
    self.user = person.pets_user.user unless person.nil?
  end
end
