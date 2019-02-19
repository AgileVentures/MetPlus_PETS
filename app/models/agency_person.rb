class AgencyPerson < ApplicationRecord
  acts_as :user

  belongs_to :agency
  belongs_to :branch
  has_many   :agency_relations
  has_many   :job_seekers, through: :agency_relations, dependent: :destroy
  has_and_belongs_to_many :agency_roles, autosave: false
  has_and_belongs_to_many :job_categories, join_table: 'job_specialities'

  enum status: [:invited, :active, :inactive]
  has_many :status_changes, as: :entity, dependent: :destroy

  validates_presence_of :agency_id

  validate :not_removing_sole_agency_admin, on: :update

  validate :job_seeker_assigned_to_job_developer

  validate :job_seeker_assigned_to_case_manager

  def invited
    invited!
    StatusChange.update_status_history(self, :invited)
  end

  def active
    active!
    StatusChange.update_status_history(self, :active)
  end

  def inactive
    inactive!
    StatusChange.update_status_history(self, :inactive)
  end

  def not_removing_sole_agency_admin
    # This validation is to prevent the removal of a sole agency admin - which
    # would result in no AgencyPerson able to perform the admin role.

    # If the AA role is set for this person we are OK
    agency_roles.each { |role| return if role.role == AgencyRole::ROLE[:AA] }

    errors[:agency_admin] << 'cannot be unset for sole agency admin.' unless
                      other_agency_admin?
  end

  def job_seeker_assigned_to_job_developer
    # If the JD role is set for this person we are OK
    agency_roles.each { |role| return if role.role == AgencyRole::ROLE[:JD] }

    if !agency_relations.empty? && !relations_with_role(:JD).empty?
      errors[:person] <<
        'cannot be assigned as Job Developer unless person has that role.'
    end
  end

  def job_seeker_assigned_to_case_manager
    # If the CM role is set for this person we are OK
    agency_roles.each { |role| return if role.role == AgencyRole::ROLE[:CM] }

    if !agency_relations.empty? && !relations_with_role(:CM).empty?
      errors[:person] <<
        'cannot be assigned as Case Manager unless person has that role.'
    end
  end

  def job_seekers_as_job_developer
    job_seekers.where(id: AgencyRelation.in_role_of(:JD).pluck(:job_seeker_id))
  end

  def job_seekers_as_case_manager
    job_seekers.where(id: AgencyRelation.in_role_of(:CM).pluck(:job_seeker_id))
  end

  def other_agency_admin?
    admins = Agency.agency_admins(agency)

    (admins.count > 1) || (admins.count == 1 && !admins.include?(self))
  end

  def sole_agency_admin?
    # Is this person even an admin?
    return false unless agency_roles.pluck(:role).include? AgencyRole::ROLE[:AA]

    not other_agency_admin?
  end

  def agency_role_ids
    agency_roles.pluck(:id)
  end

  def job_category_ids
    job_categories.pluck(:id)
  end

  def as_jd_job_seeker_ids
    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[:JD]).id

    seekers = []
    agency_relations.includes(:job_seeker)
                    .where(agency_role_id: role_id).each do |relation|
      seekers << relation.job_seeker.id
    end
    seekers
  end

  def as_cm_job_seeker_ids
    role_id = AgencyRole.find_by_role(AgencyRole::ROLE[:CM]).id

    seekers = []
    agency_relations.includes(:job_seeker)
                    .where(agency_role_id: role_id).each do |relation|
      seekers << relation.job_seeker.id
    end
    seekers
  end

  def job_developer?(agency)
    return false if self.agency != agency

    has_role?(:JD)
  end

  def case_manager?(agency)
    return false if self.agency != agency

    has_role?(:CM)
  end

  def agency_admin?(agency)
    return false if self.agency != agency

    has_role?(:AA)
  end

  def agency_person?(agency)
    self.agency == agency
  end

  private

  def has_role?(role)
    agency_roles.pluck(:role).include? AgencyRole::ROLE[role]
  end

  def relations_with_role(role_key)
    agency_relations.filter do |rel|
      rel.agency_role_id == AgencyRole.find_by_role(AgencyRole::ROLE[role_key]).id
    end
  end
end
