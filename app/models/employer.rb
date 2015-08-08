class Employer < ActiveRecord::Base
  acts_as :user
  belongs_to :company

  validates :phone, :phone => true
  validates :company, :presence => true
end
