class Employer < ActiveRecord::Base
  acts_as :user
  belongs_to :company
  has_many :jobs

  validates :phone, :phone => true
  validates :company, :presence => true
end
