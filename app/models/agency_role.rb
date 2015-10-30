class AgencyRole < ActiveRecord::Base
  has_and_belongs_to_many :agency_people
  validates_presence_of :role
  validates_length_of   :role, maximum: 40

end
