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
  
  # For the following methods, 'logged_in_user' can be either an
  # AgencyPerson object, or the User object associated with an AgencyPerson
  # In either case, this object needs to represent:
  #   an AgencyPerson object (directly or via user.actable), and,
  #   that person must be logged in
  
  def self.agency_admin(logged_in_user)
    find_user_with_role(logged_in_user, :AA)
  end
  
  def self.this_agency(logged_in_user)
    raise RunTimeError, 'Logged in user is not an agency person' unless
            logged_in_user.actable.is_a? AgencyPerson
            
    Agency.find(logged_in_user.actable.agency_id)
  end
  
  private
  
  def self.find_user_with_role(logged_in_user, role)
    return nil if not logged_in_user
    
    count = 0
    user = nil
    this_agency(logged_in_user).agency_people.each do |ap|
      ap.agency_roles.each do |ar|
        if ar.role == AgencyRole::ROLE[role]
          user = ap
          count += 1
        end
      end
    end
    return user if count == 1
    raise RunTimeError, 
      "More than one #{Agency.Person::ROLE[role]}" if count >1
    nil
  end
  
end
