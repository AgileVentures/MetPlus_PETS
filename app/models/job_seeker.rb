class JobSeeker < ActiveRecord::Base
  acts_as :user
  belongs_to :job_seeker_status
  #has_one    :resume

  has_one	   :address, as: :location
  has_many   :agency_relations
  has_many   :agency_people, through: :agency_relations
 
  validates_presence_of :year_of_birth, #:resume
  validates  :year_of_birth, :year_of_birth => true


end
