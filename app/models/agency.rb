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
  
  private
  
  def self.find_users_with_role(agency, role)
    users = []
    agency.agency_people.each do |ap|
                users << ap if ap.agency_roles && 
                               ap.agency_roles.pluck(:role).include?(role)
    end
    users
  end
  
end
