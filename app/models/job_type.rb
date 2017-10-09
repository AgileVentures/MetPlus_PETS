class JobType < ActiveRecord::Base
  has_and_belongs_to_many :jobs

  validates_presence_of :job_type
end
