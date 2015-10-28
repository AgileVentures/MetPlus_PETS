require 'rails_helper'

describe AgencyPerson, type: :model do
 
 	 describe 'Database schema' do
	    it { is_expected.to have_db_column :agency_id }
	    it { is_expected.to have_db_column :address_id }
	end

	xit "remove xit part after merging with Agency model" do 
		it{is_expected.to belong_to(:agency)} 
	end

	it{is_expected.to belong_to(:address)}
end
