require 'rails_helper'

describe CompanyRole, type: :model do

	FactoryGirl.create(:company_role, role: 'Human Resources')
	FactoryGirl.create(:company_role, role: 'Company Manager')

	it{ is_expected.to have_db_column :role } 
	it{is_expected.to validate_presence_of(:role) }
	it{ is_expected.to have_and_belong_to_many :company_people} 

	describe CompanyRole.select(:role).map(&:role) do 
		it{should include('Human Resources', 'Company Manager')}
	end

end
