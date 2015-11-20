
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

# User.find_or_create_by(email: 'salemamba@gmail.com') do |user|
#     user.first_name = "salem"
#     user.last_name  = 'amba', 
#     user.password = 'secret123',
#     user.password_confirmation = 'secret123', 
#     user.phone ='619-316-8971',
#     user.confirmed_at = DateTime.now
# end


Job.delete_all 
Company.delete_all

cp1 = Company.create(:ein => '12-2123244', :phone=> '721-234-4646',  email: 'casemanager@gmail.com',  website: 'http://www.wallmart.com', :name=> 'Walmart')
cp2 = Company.create(:ein => '13-1244445', :phone=>  '721-234-1010', email: 'casemanager2@gmail.com', website: 'http://www.target.com',   :name=> 'Target')
cp3 = Company.create(:ein => '12-1252445', :phone=> '865-234-4646', email:  'casemanager3@gmail.com', website: 'http://www.Food4less.com',:name=> 'Food4less')
cp4 = Company.create(:ein => '15-1342447', :phone=> '971-234-4646', email:  'casemanager4@gmail.com', website: 'http://www.macy.com',     :name=> 'Macy')


Job.create(:title => 'Software Developer', :description => 'Looking for a software developer intern.', :company_id => cp1.id,
            :company_person_id => '1', :job_category_id => '1' )
Job.create(:title => 'Cashier', :description => 'Looking for well qualified cashier with 5 years experience', :company_id => cp2.id,
            :company_person_id => '2', :job_category_id => '2' )
Job.create(:title => 'Driver', :description => 'Looking for a truck driver with class A license', :company_id => cp3.id,
            :company_person_id => '3', :job_category_id => '3' )
Job.create(:title => 'Security Personel', :description => 'If you have Security Guard license, and love to work  third shift, than call us.', :company_id => cp4.id,
            :company_person_id => '4', :job_category_id => '4' )

#incase rerun comes in. not necessary
JobSeekerStatus.delete_all 

['Unemployedlooking', 'Employedlooking', 'Employednotlooking'].each do |status|
	    case status 
	    when 'Unemployedlooking'
            JobSeekerStatus.find_or_create_by(:value => status, description: "A jobseeker Without any work and looking for a job.")
        when 'Employedlooking'
        	JobSeekerStatus.find_or_create_by(:value => status, description: "A jobseeker with a job and looking for a job.")
        when 'Employednotlooking'
        	JobSeekerStatus.find_or_create_by(:value => status, description: "A jobseeker with a job and not looking for a job for now.")
        end
end

['Company Manager', 'Human Resources'].each do |role|
        CompanyRole.find_or_create_by(:role => role)
end

#in case of seeding multiple times
SkillLevel.delete_all

SkillLevel.create(name: 'Beginner', 
            description: 'Entry level or minimal proficiency')
SkillLevel.create(name: 'Intermediate', 
            description: 'Proficient in some aspects, requires supervision')
SkillLevel.create(name: 'Advanced', 
            description: 'Proficient in all aspects, requires little supervision')
SkillLevel.create(name: 'Expert', 
            description: 'Proficient in all aspects, able to work indepently')
            
AgencyRole.create(role: 'Job Developer')
AgencyRole.create(role: 'Case Manager')
AgencyRole.create(role: 'Agency Manager')



