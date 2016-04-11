require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context 'single_line_address method' do
    it 'returns string for address' do
      address = FactoryGirl.build(:address, :state => "MI")
      expect(single_line_address(address)).
          to eq "#{address.street}, #{address.city}, MI #{address.zipcode}"
    end
    it 'return no-address for nil' do
      expect(single_line_address(nil)).
          to eq 'No Address'
    end
  end

  context '#full_title' do 
    
   it "base title" do 
     expect(helper.full_title()).to eq("MetPlus")
   end

   it "show page title" do 
       expect(helper.full_title("Ruby on Rails")).to eq("Ruby on Rails | MetPlus")
   end

  end

end
