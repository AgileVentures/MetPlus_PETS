class Branch < ActiveRecord::Base
  belongs_to :agency
  has_one    :address, as: :location
  has_many   :agency_people
  
  validates_presence_of   :code
  validates_length_of     :code, maximum: 8
  validates_uniqueness_of :code, scope: :agency_id
  
  validates_presence_of   :agency_id
end
