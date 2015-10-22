class JobSeekerStatus < ActiveRecord::Base

	has_many :jobseekers, class_name: "JobSeeker" 
	validates_presence_of :description, :value 
	validates_length_of :description, within: 10..255, 
				too_long: "Description too long", 
				too_short: "Description too short, at least 10 words." 
	STATUS_VALUES = ['Not looking for job', 'Active looking for work', 'Employed']
	validates_inclusion_of :value, :in => STATUS_VALUES, 
				:message => "must be one of: #{STATUS_VALUES.join(', ')}"

	
end
