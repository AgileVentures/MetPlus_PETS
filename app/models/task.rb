require 'task_manager/task_manager'
require 'task_manager/business_logic'
class Task < ActiveRecord::Base

  include TaskManager
  include BusinessLogic

  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'

  belongs_to :owner_agency, class_name: 'Agency', foreign_key: 'owner_agency_id'

  belongs_to :owner_company, class_name: 'Company', foreign_key: 'owner_company_id'

  belongs_to :user
  belongs_to :company
  belongs_to :job

  validates_with TaskOwnerValidator

  scope :today_tasks, -> {where('deferred_date IS NULL or deferred_date <= ?', Date.today)}
  scope :js_tasks, ->(job_seeker) {where('owner_user_id=?', job_seeker.user.id)}
  scope :agency_person_tasks, ->(agency_person) {where('owner_user_id=? or (owner_agency_id=? and owner_agency_role in (?))',
                                                         agency_person.user.id,
                                                         agency_person.agency.id,
                                                         agency_person.agency_roles.pluck(:role).collect{|role| AgencyRole::ROLE.key(role)})}
  scope :company_person_tasks, ->(company_person) {where('owner_user_id=? or (owner_company_id=? and owner_company_role in (?))',
                                                         company_person.user.id,
                                                         company_person.company.id,
                                                         company_person.company_roles.pluck(:role).collect{|role| CompanyRole::ROLE.key(role)})}

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
    return today_tasks.js_tasks(user) \
                if user.is_a? JobSeeker
    return today_tasks.agency_person_tasks(user) \
                   if user.is_a? AgencyPerson
    return today_tasks.company_person_tasks(user) \
                   if user.is_a? CompanyPerson
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
