class AgencyPerson < ActiveRecord::Base
  acts_as :user

  belongs_to :agency
  belongs_to :branch
  has_many   :agency_relations, dependent: :destroy
  has_many   :job_seekers, through: :agency_relations
  has_and_belongs_to_many :agency_roles, autosave: false
  has_and_belongs_to_many :job_categories, join_table: 'job_specialities'

  validates_presence_of :agency_id

  STATUS = { IVT:   'Invited',
             ACT:   'Active',
             INACT: 'Inactive' }

  validates :status, inclusion: STATUS.values

  validate :not_removing_sole_agency_admin, on: :update

  validate :job_seeker_assigned_to_job_developer

  # validate :job_seeker_assigned_to_case_manager

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

    if !agency_relations.empty? && !agency_relations.in_role_of(:JD).empty?
      errors[:person] <<
        'cannot be assigned as Job Developer unless person has that role.'
    end
  end

  def job_seeker_assigned_to_case_manager
    # If the CM role is set for this person we are OK
    agency_roles.each { |role| return if role.role == AgencyRole::ROLE[:CM] }

    if !agency_relations.empty? && !agency_relations.in_role_of(:CM).empty?
      errors[:person] <<
        'cannot be assigned as Case Manager unless person has that role.'
    end
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
    seekers = []
    agency_relations.in_role_of(:JD).each do |relation|
      seekers << relation.job_seeker.id
    end
    seekers
  end

  def as_cm_job_seeker_ids
    seekers = []
    agency_relations.in_role_of(:CM).each do |relation|
      seekers << relation.job_seeker.id
    end
    seekers
  end

  def is_agency_admin? agency
    Agency.agency_admins(agency).include?(self)
  end

end
