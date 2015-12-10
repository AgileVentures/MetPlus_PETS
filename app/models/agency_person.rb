class AgencyPerson < ActiveRecord::Base
  acts_as :user
  
  belongs_to :agency
  belongs_to :branch
  has_and_belongs_to_many :agency_roles
  has_and_belongs_to_many :job_categories, join_table: 'job_specialities'
  has_and_belongs_to_many :job_seekers, join_table: 'seekers_agency_people'

  validates_presence_of :agency_id
  
  validate :not_removing_sole_agency_admin, on: :update
  
  def not_removing_sole_agency_admin
    # This validation is to prevent the removal of a sole agency admin - which
    # would result in no AgencyPerson able to perform the admin role.
    
    # If the admin role is set for this person we are OK 
    agency_roles.each { |role| return if role.role == AgencyRole::ROLE[:AA] }
    
    errors[:agency_admin] << 'cannot be unset for sole agency admin.' unless
                      other_agency_admin?
  end
  
  def sole_agency_admin?
    # Is this person even an admin?
    return false unless agency_roles.pluck(:role).include? AgencyRole::ROLE[:AA]
    
    return false if other_agency_admin?
    
    true
  end
  
  def other_agency_admin?
    # Check if at least one other person (besides self) is an admin
    agency.agency_people.each do |person|
      next if person == self
      person.agency_roles.each { |role| return true if role.role ==
                                            AgencyRole::ROLE[:AA] }
    end
    false
  end
  
  def agency_role_ids
    agency_roles.pluck(:id)
  end
  
  def job_category_ids
    job_categories.pluck(:id)
  end
  
  def job_seeker_ids
    job_seekers.pluck(:id)
  end
  
end
