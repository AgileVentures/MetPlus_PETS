class JobSeekerStatus < ActiveRecord::Base
	has_many :jobseekers, class_name: "JobSeeker" 
	validates_presence_of :description, :value 
	validates_length_of :description, within: 10..255, 
				too_long:  "is too long (maximum is 255 characters)",
				too_short: "is too short (minimum is 10 characters)" 
end
