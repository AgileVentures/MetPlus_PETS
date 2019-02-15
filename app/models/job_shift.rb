class JobShift < ApplicationRecord
  has_and_belongs_to_many :jobs

  validates_presence_of :shift
end
