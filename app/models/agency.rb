class Agency < ActiveRecord::Base
  has_many :agency_people
  has_many :addresses, as: :location
  has_and_belongs_to_many :companies
  
  validates_presence_of :name, :website, :phone, :email
  validates_length_of   :name, maximum: 100
  validates_length_of   :website, maximum: 200
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
end
