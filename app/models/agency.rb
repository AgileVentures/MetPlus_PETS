class Agency < ActiveRecord::Base
  has_many :agency_people
  has_many :branches
  has_and_belongs_to_many :companies

  validates_presence_of :name, :website, :phone, :email
  validates_length_of   :name, maximum: 100
  validates_length_of   :website, maximum: 200
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
  validates :fax, :phone => true, allow_blank: true

  def self.agency_admins(agency)
    find_users_with_role(agency, AgencyRole::ROLE[:AA])
  end

  def self.this_agency(user)
    raise RuntimeError, 'Logged in user is not an agency person' unless
            user.actable.is_a? AgencyPerson

    user.actable.agency
  end

  def agency_people_on_role role
    users = []
    agency_people.each do |person|
      users << person if person.agency_roles &&
          person.agency_roles.pluck(:role).include?(role)
    end

    users
  end

  # MULTIPLE AGENCIES: the code below needs to change
  def self.all_agency_people_emails
    first.agency_people.pluck(:email)
  end
  ###################################################

  def self.job_developers agency
    find_users_with_role agency, AgencyRole::ROLE[:JD]
  end

  def self.case_managers agency
    find_users_with_role agency, AgencyRole::ROLE[:CM]
  end

  private

  def self.find_users_with_role(agency, role)
    agency.agency_people_on_role role
  end


end
