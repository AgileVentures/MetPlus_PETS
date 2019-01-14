FactoryBot.define do
  sequence(:ein) do |n|
    n = n.next
    "12-346#{n.to_s.rjust(4, '0')}"
  end

  factory :company do
    name { 'Widgets, Inc.' }
    ein
    phone  { '123 123 1234' }
    fax    { '321 321 4321' }
    email { 'contact@ymail.com' }
    job_email { 'jobs@ymail.com' }
    website { 'http://www.widgets-r-us.com' }
    status  { 'active' }
    agencies { [FactoryBot.create(:agency)] }
  end

  factory :inactive_company, class: Company do
    name { 'The Company, Inc.' }
    ein
    phone  { '789 789 7890' }
    fax    { '987 987 9870' }
    email { 'contact@company.ymail.com' }
    job_email { 'jobs@company.ymail.com' }
    website { 'http://www.thecompany.com' }
    status  { 'inactive' }
    agencies { [FactoryBot.create(:agency)] }
  end
end
