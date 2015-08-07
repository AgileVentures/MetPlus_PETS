class Company < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  validates :phone, :phone => true
  validates :ein, :presence => true,
                  :einNumber => true
end
