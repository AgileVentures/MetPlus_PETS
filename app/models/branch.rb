class Branch < ActiveRecord::Base
  belongs_to :agency
  belongs_to :address
  has_many   :agency_people
end
