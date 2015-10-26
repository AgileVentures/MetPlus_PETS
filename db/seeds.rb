
# case Rails.env
#   when "development"
#     comp1 = FactoryGirl.create(:company, :name => 'Company 1', :email => 'info@company1.com')
#     comp2 = FactoryGirl.create(:company, :name => 'Company 2', :email => 'info@company2.com')
#     emp1 = FactoryGirl.create(:employer, :first_name => 'John', :email => 'john@company1.com', :company => comp1)
#     emp2 = FactoryGirl.create(:employer, :first_name => 'Tom', :email => 'tom@company1.com', :company => comp1)
#     emp3 = FactoryGirl.create(:employer, :first_name => 'Mary', :email => 'mary@company2.com', :company => comp2)

#     skill1 = FactoryGirl.create(:skill, :name => 'Handyman', :description => 'Some handy man')
#     skill2 = FactoryGirl.create(:skill, :name => 'Software Developer', :description => 'Develops software')
#     skill3 = FactoryGirl.create(:skill, :name => 'Cook', :description => 'Cooks very nice food')
#     skill4 = FactoryGirl.create(:skill, :name => 'English teacher', :description => 'Teaches english')
#     skill5 = FactoryGirl.create(:skill, :name => 'Manager', :description => 'Someone that manages')
#     skill6 = FactoryGirl.create(:skill, :name => 'Administrative', :description => 'Administrative work')

#     job1 = FactoryGirl.create(:job, :company => comp1, :employer => emp1, :title => 'Software developer',
#                               :description => 'Looking for a software developer that can work miracles')
#     job1.required_skills << skill2
#     job1.nice_to_have_skills << skill5
#     job1.save

#     job2 = FactoryGirl.create(:job, :company => comp1, :employer => emp2, :title => 'Teacher',
#                               :description => 'Looking for a nice english teacher to do some teaching')
#     job2.required_skills << skill4
#     job2.save

#     job3 = FactoryGirl.create(:job, :company => comp2, :employer => emp3, :title => 'The Cook',
#                               :description => 'Cooking that can cook and do some handywork')
#     job3.required_skills << skill3
#     job3.nice_to_have_skills << skill1
#     job3.save

#     job4 = FactoryGirl.create(:job, :company => comp1, :employer => emp3, :title => 'Need a person',
#                               :description => 'Need someone that can do a bunch of things')
#     job4.required_skills << skill6
#     job4.required_skills << skill5
#     job4.nice_to_have_skills << skill1
#     job4.nice_to_have_skills << skill4
#     job4.save
# end
#incase rerun comes in.
JobSeekerStatus.delete_all 
puts "Creating staus value..."

['Unemployed actively looking for job', 'Employed actively looking for job', 'Employed not looking for job'].each do |status|
        JobSeekerStatus.find_or_create_by(:value => status)
end




