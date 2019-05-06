class JobSeeker < ApplicationRecord
  acts_as :user
  has_many :resumes, dependent: :destroy

  has_one :address, as: :location, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many   :agency_relations
  has_many   :agency_people, through: :agency_relations, dependent: :destroy

  validates_presence_of :year_of_birth
  has_many   :job_applications
  has_many   :jobs, through: :job_applications, dependent: :destroy

  validates  :year_of_birth, year_of_birth: true

  belongs_to :job_seeker_status
  validates_presence_of :job_seeker_status

  scope :consent, -> { where(consent: true) }

  delegate :unconfirmed_email, to: :user

  def status
    job_seeker_status
  end

  def job_seeker?
    true
  end

  def latest_application
    job_applications.order(:created_at).last
  end

  def applied_to_job?(job)
    job_applications.pluck(:job_id).include? job.id
  end

  def self.with_ap_in_role(role_key, agency_person)
    AgencyRelation.in_role_of(role_key)
                  .where(agency_person: agency_person)
                  .pluck(:job_seeker_id)
  end

  def job_developer
    find_agency_person(:JD)
  end

  def assign_job_developer(job_developer, agency)
    unless job_developer.job_developer? agency
      raise "User #{job_developer.full_name} is not a Job Developer"
    end

    assign_agency_person(job_developer, :JD)
  end

  def case_manager
    find_agency_person(:CM)
  end

  def assign_case_manager(case_manager, agency)
    unless case_manager.case_manager? agency
      raise "User #{case_manager.full_name} is not a Case Manager"
    end

    assign_agency_person(case_manager, :CM)
  end

  def self.job_seekers_without_job_developer
    where.not(id: AgencyRelation.in_role_of(:JD).pluck(:job_seeker_id))
         .includes(:job_seeker_status, :job_applications)
         .order('users.last_name')
  end

  def self.job_seekers_without_case_manager
    where.not(id: AgencyRelation.in_role_of(:CM).pluck(:job_seeker_id))
         .includes(:job_seeker_status, :job_applications)
         .order('users.last_name')
  end

  def application_for_job(job)
    job_applications.where(job: job)[0]
  end

  private

  # Helper methods for associating job seekers with agency people
  # These business rules are enforced:
  # 1) A job seeker can have only one case manager
  # 2) A job seeker can have only one job developer ('primary' JD)

  def assign_agency_person(agency_person, role_key)
    ap_relation = find_agency_person_relation(role_key)
    if ap_relation
      # Is this role assigned already to an agency person?
      # If so, is this the same agency person? - then we're done
      return if ap_relation.agency_person == agency_person

      # Otherwise, reassign agency person role for this job seeker
      ap_relation.agency_person = agency_person
      ap_relation.save
    else
      # Otherwise, assign this agency person, in this role, to job seeker
      AgencyRelation.create(agency_person: agency_person,
                            job_seeker: self,
                            agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[role_key]))
    end
  end

  def find_agency_person(role_key)
    agency_relation = find_agency_person_relation(role_key)

    (agency_relation ? agency_relation.agency_person : nil)
  end

  def find_agency_person_relation(role_key)
    # Returns AgencyRelation instance if an agency person, acting in the
    # specific role, is found for this job seeker
    unless agency_relations.empty?
      ap_relation = agency_relations.in_role_of(role_key)[0]
      return ap_relation if ap_relation
    end
    nil # return nil if no agency person found for that role
  end
end
