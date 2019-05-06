class CompanyRole < ApplicationRecord
  validates_presence_of :role
  validates_length_of :role, maximum: 40
  has_and_belongs_to_many :company_people,
                          join_table: 'company_people_roles'

  ROLE = { CC: 'Company Contact',
           CA: 'Company Admin' }

  validates :role, inclusion: ROLE.values
end
