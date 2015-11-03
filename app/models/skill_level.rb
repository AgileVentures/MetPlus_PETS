class SkillLevel < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :name, maximum: 20
  validates_presence_of :description
  validates_length_of :name, maximum: 100
end
