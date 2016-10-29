class JobApplicationPolicy < ApplicationPolicy
  	
	def accept?
		company_person? user
	end

	def reject?
		company_person? user	
	end

	def show?
		company_person? user		
	end

private

	def company_person? user
		User.is_company_person? user
	end
end
