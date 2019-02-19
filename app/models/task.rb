class Task < ApplicationRecord
  include TaskManager::TaskManager
  include TaskManager::BusinessLogic

  belongs_to :owner, class_name: 'User', foreign_key: 'owner_user_id'

  belongs_to :owner_agency, class_name: 'Agency', foreign_key: 'owner_agency_id'

  belongs_to :owner_company, class_name: 'Company', foreign_key: 'owner_company_id'

  belongs_to :user
  belongs_to :company
  belongs_to :job_application
  belongs_to :job

  validates_with TaskOwnerValidator

  scope :today_tasks, lambda {
    where('deferred_date IS NULL or deferred_date < ?', Date.today + 1)
  }
  scope :open_tasks, -> { today_tasks.where('status != ?', STATUS[:DONE]) }
  scope :new_tasks, -> { today_tasks.where('status = ?', STATUS[:NEW]) }
  scope :active_tasks, lambda {
    today_tasks.where('status != ? and status != ?', STATUS[:DONE], STATUS[:NEW])
  }
  scope :closed_tasks, -> { where('status = ?', STATUS[:DONE]) }
  scope :user_tasks, ->(user) { where('owner_user_id=?', user.user.id) }
  scope :agency_person_tasks, lambda { |agency_person|
    where('(owner_agency_id=? and owner_agency_role in (?))',
          agency_person.agency.id,
          agency_person.agency_roles.pluck(:role).map do |role|
            AgencyRole::ROLE.key(role)
          end)
  }
  scope :company_person_tasks, lambda { |company_person|
    where('owner_user_id=? or (owner_company_id=? and owner_company_role in (?))',
          company_person.user.id,
          company_person.company.id,
          company_person.company_roles.pluck(:role).map do |role|
            CompanyRole::ROLE.key(role)
          end)
  }
  scope :agency_tasks, lambda { |user|
    where('(owner_agency_id = ? or owner_user_id in (?))',
          user.agency.id, user.agency.agency_people.map { |a| a.acting_as.id }.map)
  }
  scope :company_tasks, lambda { |user|
    where('(owner_company_id = ? or owner_user_id in (?))',
          user.company.id, user.company.company_people.map { |a| a.acting_as.id }.map)
  }

  scope :job_seeker_target, ->(user) { where('user_id = ?', user.pets_user.user.id) }
  scope :company_target, ->(company) { where('company_id = ?', company.id) }
  scope :job_application_target, lambda { |job_application|
    where('job_application_id = ?', job_application.id)
  }
  scope :open_tasks_of_type, lambda { |task_type|
    open_tasks.where('task_type = ?', task_type)
  }

  def task_owner
    return owner.pets_user unless owner.nil?
    if owner_a_agency_and_as_a_role?
      return owner_agency.agency_people_on_role AgencyRole::ROLE[owner_agency_role.to_sym]
    elsif owner_a_company_and_as_a_company_role?
      return owner_company.people_on_role CompanyRole::ROLE[owner_company_role.to_sym]
    end

    nil
  end

  def task_owner=(
    user: nil,
    agency: { agency: nil, role: nil },
    company: { company: nil, role: nil }
  )
    self.owner = nil
    self.owner = user.user unless user.nil?
    self.owner_agency = agency[:agency]
    self.owner_agency_role = agency[:role]
    self.owner_company = company[:company]
    self.owner_company_role = company[:role]
  end

  def self.find_by_owner_user_open(user)
    open_tasks.user_tasks(user)
  end

  def self.find_by_owner_user_closed(user)
    closed_tasks.user_tasks(user)
  end

  def self.find_by_agency(user)
    today_tasks.agency_tasks(user)
  end

  def self.find_by_agency_new(user)
    new_tasks.agency_tasks(user)
  end

  def self.find_by_agency_active(user)
    active_tasks.agency_tasks(user)
  end

  def self.find_by_user_closed(user)
    closed_tasks.user_tasks(user)
  end

  def self.find_by_agency_closed(user)
    if user.agency_admin?(user.agency)
      closed_tasks.agency_tasks(user)
    else
      closed_tasks.user_tasks(user)
    end
  end

  def self.find_by_company_open(user)
    if user.company_admin?(user.company)
      open_tasks.company_person_tasks(user)
    else
      open_tasks.user_tasks(user)
    end
  end

  def self.find_by_company_new(user)
    new_tasks.company_tasks(user)
  end

  def self.find_by_company_active(user)
    active_tasks.company_tasks(user)
  end

  def self.find_by_company_closed(user)
    if user.company_admin?(user.company)
      closed_tasks.company_tasks(user)
    else
      closed_tasks.user_tasks(user)
    end
  end

  def self.find_by_target_job_seeker_open(job_seeker)
    open_tasks.job_seeker_target job_seeker
  end

  def self.find_by_type_and_target_job_seeker_open(task_type, job_seeker)
    open_tasks_of_type(task_type).job_seeker_target job_seeker
  end

  def self.find_by_type_and_target_company_open(task_type, company)
    open_tasks_of_type(task_type).company_target company
  end

  def self.find_by_type_and_target_job_application_open(task_type, job_application)
    open_tasks_of_type(task_type).job_application_target job_application
  end

  def target
    return person unless person.nil?
    return company unless company.nil?
    return job_application unless job_application.nil?
    return job unless job.nil?

    nil
  end

  def target=(target)
    case target
    when User, AgencyPerson, CompanyPerson, JobSeeker
      set_targets(target.pets_user.user, nil, nil, nil)
    when JobApplication
      set_targets(nil, nil, target, nil)
    when Company
      set_targets(nil, target, nil, nil)
    when Job
      set_targets(nil, nil, nil, target)
    end
  end

  def person
    return nil if user.nil?

    user.pets_user
  end

  def person=(person)
    self.user = nil
    self.user = person.pets_user.user unless person.nil?
  end

  private

  def set_targets(person, company, job_application, job)
    self.person = person
    self.company = company
    self.job_application = job_application
    self.job = job
  end

  def owner_a_agency_and_as_a_role?
    !owner_agency.nil? && !owner_agency_role.nil?
  end

  def owner_a_company_and_as_a_company_role?
    !owner_company.nil? && !owner_company_role.nil?
  end
end
