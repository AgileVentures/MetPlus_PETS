class Company < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  :includes
  validates :phone, :phone => true
  validates :ein, :presence => true,
                  :einNumber => true
  validates :email, :email => true
end
