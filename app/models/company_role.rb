class CompanyRole < ActiveRecord::Base
	validates_presence_of :role 
	has_and_belongs_to_many :company_people 
	
end
