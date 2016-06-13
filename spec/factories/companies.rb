FactoryGirl.define do

  sequence(:ein) do |n|
    n = n.next
    "12-346#{ n.to_s.rjust(4, "0")}"
  end

  factory :company do
    name   'Widgets, Inc.'
    ein
    phone  '123 123 1234'
    fax    '321 321 4321'
    email   'contact@widgets.com'
    job_email   'jobs@widgets.com'
    website 'http://www.widgets-r-us.com'
    status  Company::STATUS[:PND]
  end

end
