class JobSeeker < ActiveRecord::Base
  acts_as :user
  belongs_to :job_seeker_status
  #has_one    :resume

  has_one	   :address, as: :location
  has_many   :agency_relations
  has_many   :agency_people, through: :agency_relations

  validates_presence_of :year_of_birth, :job_seeker_status_id #,:resume
  validates  :year_of_birth, :year_of_birth => true


  # def case_manager=(cm_person)
  #   AgencyRelation.assign_case_manager_to_job_seeker(self, cm_person)
  # end

  # def case_manager
  #   AgencyRelation.case_manager_for_job_seeker(self)
  # end
  #
  # def job_developer
  #   AgencyRelation.job_developer_for_job_seeker(self)
  # end
  def is_job_seeker?
    true
  end


  def case_manager
    find_agency_person(:CM)
  end

  def job_developer
    find_agency_person(:JD)
  end

  def assign_case_manager(case_manager)
    assign_agency_person(case_manager, :CM)
  end

  def assign_job_developer(job_developer)
    assign_agency_person(job_developer, :JD)
  end

  def assign_agency_person(agency_person, role_key)
    raise 'Not a job seeker'   if not self.is_a? JobSeeker
    raise 'Not an agency person' if not agency_person.is_a? AgencyPerson
    raise 'AgencyPerson does not have appropriate role' if
            agency_person.agency_roles.empty? ||
            !agency_person.agency_roles.
                  include?(AgencyRole.find_by_role(AgencyRole::ROLE[role_key]))

    ap_relation = self.agency_relations.in_role_of(role_key)[0]
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
    raise 'Not a job seeker' if not self.is_a? JobSeeker
    if not self.agency_relations.empty?
      ap_relation = self.agency_relations.in_role_of(role_key)[0]
      return ap_relation.agency_person if ap_relation
    end
    nil # return nil if no agency person found for that role
  end

end
