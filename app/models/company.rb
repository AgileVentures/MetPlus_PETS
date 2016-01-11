class Company < ActiveRecord::Base
<<<<<<< HEAD
  has_many :company_people
  accepts_nested_attributes_for :company_people
  
  has_many :jobs
  
  has_many :addresses, as: :location
  accepts_nested_attributes_for :addresses
  
=======

  has_many :company_people, dependent: :destroy
    accepts_nested_attributes_for :company_people
  has_many :jobs

  has_many :addresses, as: :location, dependent: :destroy
    accepts_nested_attributes_for :addresses

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
  has_and_belongs_to_many :agencies


  validates :ein,   :ein_number => true
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
  validates_presence_of :name

  STATUS = { PND:   'Pending', # Company has registered but not yet approved
             ACT:   'Active',
             INACT: 'Inactive' }

  validates :status, inclusion: STATUS.values
 
end
