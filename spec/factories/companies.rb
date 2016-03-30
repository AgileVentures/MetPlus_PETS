FactoryGirl.define do

  sequence(:ein) do |n|
    n = n.next
    ein = "12-346#{n}"
    while ein.length < 10 do
      ein += '0'
    end
    ein
  end

  factory :company do
    name   'Widgets, Inc.'
    ein
    phone  '123 123 1234'
    fax    '321 321 4321'
    email   'contact@widgets.com'
    website 'http://www.widgets-r-us.com'
    status  Company::STATUS[:PND]
  end

end
