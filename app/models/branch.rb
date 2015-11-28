class Branch < ActiveRecord::Base
  belongs_to :agency
  has_one    :address, as: :location
  has_many   :agency_people
end
