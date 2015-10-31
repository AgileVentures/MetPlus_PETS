class Skill < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :description
  
  has_and_belongs_to_many :job_categories
end
