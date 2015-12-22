class Company < ActiveRecord::Base
  has_many :company_people
  has_many :jobs
  has_many :addresses, as: :location
  has_and_belongs_to_many :agencies


  validates :ein,   :ein_number => true
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
  validates_presence_of :name

end
