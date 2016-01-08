class CompanyPerson < ActiveRecord::Base
  acts_as :user
  belongs_to :company
  belongs_to :address
  has_and_belongs_to_many :company_roles,
                          join_table: 'company_people_roles',
                          autosave: false


  STATUS = { PND:   'Pending', # Company has registered but not yet approved
             IVT:   'Invited', # Company approved, invite sent to confirm account
             ACT:   'Active',
             INACT: 'Inactive' }

  validates :status, inclusion: STATUS.values

end
