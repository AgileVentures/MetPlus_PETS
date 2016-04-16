class JobSeeker < ActiveRecord::Base
  acts_as :user
  belongs_to :job_seeker_status
  has_many   :resumes

  has_one    :address, as: :location
  has_many   :agency_relations
  has_many   :agency_people, through: :agency_relations

  has_many   :job_applications
  has_many   :jobs, through: :job_applications

  validates  :year_of_birth, :year_of_birth => true


  def is_job_seeker?
    true
  end

  def self.js_without_jd
    where("job_seekers.id not in (?)", AgencyRelation.in_role_of(:JD).pluck(:job_seeker_id)).order("users.last_name")
  end

  def self.your_jobseekers_jd(job_developer)
    # this method serves the Job Developer home page, hence the "your"
    where(:id => AgencyRelation.in_role_of(:JD).where(:agency_person => job_developer).pluck(:job_seeker_id)).order("users.last_name")

  end

  def job_developer
    find_agency_person(:JD)
  end

  def assign_job_developer(job_developer, agency)
    raise "User #{job_developer.full_name} is not a Job Developer" unless job_developer.is_job_developer? agency
    assign_agency_person(job_developer, :JD)
  end

  def case_manager
    find_agency_person(:CM)
  end

  def assign_case_manager(case_manager, agency)
    raise "User #{case_manager.full_name} is not a Case Manager" unless case_manager.is_case_manager? agency
    assign_agency_person(case_manager, :CM)
  end

  private
  # Helper methods for associating job seekers with agency people
  # These business rules are enforced:
  # 1) A job seeker can have only one case manager
  # 2) A job seeker can have only one job developer ('primary' JD)

  def assign_agency_person(agency_person, role_key)
    ap_relation = find_agency_person(role_key)
    if ap_relation
      # Is this role assigned already to an agency person?

      # If so, is this the same agency person? - then we're done
      return if ap_relation.agency_person == agency_person

      # Otherwise, reassign case manager role for this job seeker
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
    if not self.agency_relations.empty?
      ap_relation = self.agency_relations.in_role_of(role_key)[0]
      return ap_relation.agency_person if ap_relation
    end
    nil # return nil if no agency person found for that role
  end

end
