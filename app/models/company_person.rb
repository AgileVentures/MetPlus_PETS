class CompanyPerson < ActiveRecord::Base
  acts_as :user 
  belongs_to :company
  belongs_to :address
  has_and_belongs_to_many :company_roles, join_table: 'company_people_roles'
end
