FactoryGirl.define do
  sequence :code do |n| 
    "00#{n}"
  end
  
  factory :branch do
    agency
    address
    code 
  end

end
