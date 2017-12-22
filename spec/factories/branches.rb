FactoryBot.define do
  sequence :code do |n|
    "BR00#{n}"
  end

  factory :branch do
    agency
    address
    code
  end
end
