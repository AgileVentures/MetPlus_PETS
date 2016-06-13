class AgencyRelation < ActiveRecord::Base
  belongs_to :agency_person
  belongs_to :job_seeker
  belongs_to :agency_role

  validates_presence_of :agency_person, :job_seeker, :agency_role

  def self.in_role_of role_key
    where(agency_role_id: AgencyRole.find_by_role(AgencyRole::ROLE[role_key]).id)
  end

  # def self.in_role role_key
  #   AgencyRelation.where(agency_role_id: AgencyRole.find_by_role(AgencyRole::ROLE[role_key]).id).collect(&:job_seeker)
  # end



end
