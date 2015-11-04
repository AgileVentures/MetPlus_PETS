class Company < ActiveRecord::Base
  has_many :company_people
  has_many :jobs
  has_many :addresses, as: :location
  has_and_belongs_to_many :agencies

  validates_presence_of :name, :ein, :website, :phone, :email
  validates_length_of   :name, maximum: 100
  validates_length_of   :website, maximum: 200
  validates :ein,   :presence => true
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
  
end
