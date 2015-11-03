class Company < ActiveRecord::Base
  has_many :company_people
  has_many :addresses, as: :location

  validates_presence_of :name, :ein, :website, :phone, :email
  validates_length_of   :name, maximum: 100
  validates_length_of   :website, maximum: 200
  validates :phone, :phone => true
  validates :email, :email => true
  validates :website, :website => true
  
end
