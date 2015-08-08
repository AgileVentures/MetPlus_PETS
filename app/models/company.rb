class Company < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  has_many :employers

  validates :phone, :phone => true
  validates :ein, :presence => true,
                  :einNumber => true
  validates :email, :email => true
  validates :website, :url => true
end
