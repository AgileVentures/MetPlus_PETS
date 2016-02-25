FactoryGirl.define do

  factory :company do
    name   'Widgets, Inc.'
    sequence(:ein) do |n|
      ein = "12-345#{n}"
      while ein.length < 10 do
        ein += '0'
      end
      ein
    end
    phone  '123 123 1234'
    fax    '321 321 4321'
    email   'contact@widgets.com'
    website 'http://www.widgets-r-us.com'
    status  Company::STATUS[:PND]
  end

end
