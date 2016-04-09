FactoryGirl.define do

  sequence(:ein) do |n|
    n = n.next
    "12-346#{ n.to_s.rjust(4, "0")}"
  end

  factory :company do
    name   'Widgets, Inc.'
# <<<<<<< HEAD
#     sequence(:ein) do |n|
#       s = "#{(1..9).to_a.shuffle[0..9].join}"
#       ein = "#{s[0,2]}-#{s[2,9]}"
#       # n = n.next if (n % 10 == 0)
#       # ein = "12-345#{n}"
#       # while ein.length < 10 do
#       #   ein += '0'
#       # end 
#     end
# =======
    ein

    phone  '123 123 1234'
    fax    '321 321 4321'
    email   'contact@widgets.com'
    website 'http://www.widgets-r-us.com'
    status  Company::STATUS[:PND]
  end

end
