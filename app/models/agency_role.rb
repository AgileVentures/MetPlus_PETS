class AgencyRole < ApplicationRecord
  has_and_belongs_to_many :agency_people,
                          join_table: 'agency_people_roles'
  validates_presence_of :role
  validates_length_of   :role, maximum: 40

  ROLE = { JD: 'Job Developer',
           CM: 'Case Manager',
           AA: 'Agency Admin' }

  validates :role, inclusion: ROLE.values
end
