require 'rails_helper'

describe CompanyRole, type: :model do

	    it{ is_expected.to have_db_column :role } 
		it{is_expected.to validate_presence_of(:role) } 

        
		it "once merged with company people model" do 
			pending "edit 'it' block"
		    is_expected.to have_and_belong_to_many :company_people 
		end
		
  
end
