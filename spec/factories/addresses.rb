FactoryBot.define do
  factory :address do
    location { |a| a.association(:company) }
    street '3940 Main Street'
    city 'Detroit'
    zipcode '92105'
    state 'Michigan'
  end
end
