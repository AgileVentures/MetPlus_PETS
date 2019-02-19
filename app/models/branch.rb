class Branch < ApplicationRecord
  belongs_to :agency

  has_one    :address, as: :location, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many :agency_people, dependent: :nullify

  validates_presence_of   :code
  validates_length_of     :code, maximum: 8
  validates_uniqueness_of :code, scope: :agency_id

  validates_presence_of   :agency_id
end
