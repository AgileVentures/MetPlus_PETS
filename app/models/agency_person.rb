class AgencyPerson < ActiveRecord::Base
  belongs_to :address
  belongs_to :agency
end
