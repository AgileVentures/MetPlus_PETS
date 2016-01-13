
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
#     user.last_name  = 'amba'
#     user.password = 'secret123'
#     user.password_confirmation = 'secret123'
#     user.phone ='619-316-8971'
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
    @jss1 = JobSeekerStatus.find_or_create_by(:value => status,
              description: "A jobseeker Without any work and looking for a job.")
  when 'Employedlooking'
    @jss2 = JobSeekerStatus.find_or_create_by(:value => status,
              description: "A jobseeker with a job and looking for a job.")
  when 'Employednotlooking'
    @jss3 = JobSeekerStatus.find_or_create_by(:value => status,
              description: "A jobseeker with a job and not looking for a job for now.")
  end
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

# Create all agency roles - this should stay in production version of this file
AgencyRole::ROLE.each_value do |agency_role|
  AgencyRole.create(role: agency_role)
end

# Create all company roles - - this should stay in production version of this file
CompanyRole::ROLE.each_value do |company_role|
  CompanyRole.create(role: company_role)
end

# Create a default agency, agency branches, agency admin and agency manager
agency = Agency.create!(name: 'MetPlus', website: 'metplus.org',
          phone: '111 222 3333', fax: '333 444 5555',
          email: 'pets_admin@metplus.org',
          description: 'Michigan Employment & Training Plus, (MET|PLUS) is a 501 (c) 3, Vocational Training non-profit organization that strives to assist Michigan jobseekers with invaluable training and job development that will put them on a career path to success.')

branch = Branch.create(code: '001', agency: agency)
branch.address = Address.create!(city: 'Detroit',
            street: '123 Main Street', zipcode: 48201)

branch = Branch.create(code: '002', agency: agency)
branch.address = Address.create!(city: 'Detroit',
            street: '456 Sullivan Street', zipcode: 48204)

branch = Branch.create(code: '003', agency: agency)
branch.address = Address.create!(city: 'Detroit',
            street: '3 Auto Drive', zipcode: 48206)

# Job Seekers
js1 = JobSeeker.create(first_name: 'Tom', last_name: 'Seeker',
                      email: 'tom@gmail.com', password: 'qwerty123',
              year_of_birth: '1980', resume: 'text',
          job_seeker_status: @jss1, confirmed_at: Time.now)

js2 = JobSeeker.create(first_name: 'Mary', last_name: 'McCaffrey',
                      email: 'mary@gmail.com', password: 'qwerty123',
              year_of_birth: '1970', resume: 'text',
          job_seeker_status: @jss2, confirmed_at: Time.now)

js3 = JobSeeker.create(first_name: 'Frank', last_name: 'Williams',
                      email: 'frank@gmail.com', password: 'qwerty123',
              year_of_birth: '1970', resume: 'text',
          job_seeker_status: @jss3, confirmed_at: Time.now)

# Agency People
agency_aa = AgencyPerson.new(first_name: 'John', last_name: 'Smith',
                      agency_id: agency.id, email: 'pets_admin@metplus.org',
                      password: 'qwerty123', confirmed_at: Time.now,
                      branch_id: agency.branches[0].id,
                      status: AgencyPerson::STATUS[:ACT])
agency_aa.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:AA])
agency_aa.save!

agency_cm_and_jd = AgencyPerson.new(first_name: 'Chet', last_name: 'Pitts',
                      agency_id: agency.id, email: 'chet@metplus.org',
                      password: 'qwerty123', confirmed_at: Time.now,
                      branch_id: agency.branches[1].id,
                      status: AgencyPerson::STATUS[:ACT])
agency_cm_and_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:CM])
agency_cm_and_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:JD])
agency_cm_and_jd.save!
agency_cm_and_jd.agency_relations <<
      AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:CM]),
                          job_seeker: js1)
agency_cm_and_jd.agency_relations <<
      AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:JD]),
                          job_seeker: js2)
agency_cm_and_jd.save!

agency_jd = AgencyPerson.new(first_name: 'Jane', last_name: 'Doe',
                      agency_id: agency.id, email: 'jane@metplus.org',
                      password: 'qwerty123', confirmed_at: Time.now,

                      branch_id: agency.branches[2].id,
                      status: AgencyPerson::STATUS[:ACT])

agency_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:JD])
agency_jd.save!
agency_jd.agency_relations <<
      AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:JD]),
                          job_seeker: js3)


jobseeker = JobSeeker.create(first_name: 'abc',last_name:'def',email:'vijaya.karumudi1@gmail.com', password:'dfg123',password_confirmation:'dfg123',phone:'345-890-7890',year_of_birth:
"1990", confirmed_at: Time.now)



# Job Categories
JobCategory.create(name: 'SW Developer - RoR',
            description: 'Ruby on Rails backend developer')
JobCategory.create(name: 'SW Developer - JS',
            description:  'Javascript frontend developer')
JobCategory.create(name: 'SW Developer - Java',
            description: 'Java backend developer')
JobCategory.create(name: 'SW Project Manager - Agile',
            description: 'Manages Agile SW development projects')
JobCategory.create(name: 'SW Project Manager - Waterfall',
            description: 'Manages SW development projects using waterfall SDLC')
JobCategory.create(name: 'Product Manager - SaaS',
            description: 'Manages SaaS product development and commecialization')
                      


jobseeker = JobSeeker.create(first_name: 'abc',last_name:'def',email:'vijaya.karumudi1@gmail.com', password:'dfg123',password_confirmation:'dfg123',phone:'345-890-7890',year_of_birth:
"1990", confirmed_at: Time.now)




JobSeeker.create(first_name: 'Mary', last_name: 'McCaffrey', 
                      email: 'mary@gmail.com', password: 'qwerty123', 
              year_of_birth: '1970', resume: 'text',
          job_seeker_status: @jss2, confirmed_at: Time.now)
                      
JobSeeker.create(first_name: 'Frank', last_name: 'Williams', 
                      email: 'frank@gmail.com', password: 'qwerty123', 
              year_of_birth: '1970', resume: 'text',
          job_seeker_status: @jss3, confirmed_at: Time.now)



