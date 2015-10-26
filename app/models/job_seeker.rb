class JobSeeker < ActiveRecord::Base
  acts_as :user
  belongs_to :job_seeker_status
  #has_one    :resume 
  has_one	   :address, as: :location
  has_and_belongs_to_many :agency_people, :join_table => "agencies_seekers" 
  validates_presence_of :year_of_birth, :resume
  YEARS = 100 
  validate :validate_year_of_birth  


  private 
  	def validate_year_of_birth

  	 self.year_of_birth =~/\A\d{4}\z/ ? year=self.year_of_birth :
  	         errors.add(:year_of_birth, "cannot be more than or less 4 digits")
  	         
  	  if year 
  	  	 (year.to_i<=Date.today.year)&&( year.to_i>=(Date.today.year - YEARS)) ? 
  	  	         self.year_of_birth = year.to_s : errors.add(:year_of_birth, 
  	  	         	 "should be between #{Date.today.year}-#{Date.today.year-YEARS}")
  	  end
      
  	end
end
