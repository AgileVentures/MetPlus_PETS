
require 'ffaker'

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
# User.find_or_create_by(email: 'salemamba1@gmail.com') do |user|
#     user.first_name = "salem"
#     user.last_name  = 'amba'
#     user.password = 'secret123'
#     user.password_confirmation = 'secret123'
#     user.phone ='619-316-8971'
#     user.confirmed_at = DateTime.now
# end

#incase rerun comes in. not necessary
JobSeekerStatus.delete_all
Job.delete_all
Company.delete_all
Address.delete_all
CompanyPerson.delete_all
JobCategory.delete_all
SkillLevel.delete_all

['Unemployedlooking', 'Employedlooking', 'Employednotlooking'].each do |status|
  case status
  when 'Unemployedlooking'
    @jss1 = JobSeekerStatus.find_or_create_by(:value => status,
            description: "A jobseeker Without any work and looking for a job.")
  when 'Employedlooking'
    @jss2 = JobSeekerStatus.find_or_create_by(:value => status,
              description: "A jobseeker with a job and looking for a job.")
  when 'Employednotlooking'
    @jss3=JobSeekerStatus.find_or_create_by(:value => status,
          description: "A jobseeker with a job and not looking
                        for a job for now.")
  end
end

#AgencyRole
# Create all agency roles - this should stay in production version of this file
AgencyRole::ROLE.each_value do |agency_role|
  AgencyRole.create(role: agency_role)
end
#CompanyRole
# Create all company roles - - this should stay in production
CompanyRole::ROLE.each_value do |company_role|
  CompanyRole.create(role: company_role)
end

# Create a default agency, agency branches, agency admin and agency manager
agency = Agency.create!(name: 'MetPlus', website: 'metplus.org',
            phone: '111 222 3333', fax: '333 444 5555',
            email: 'pets@metplus.org',
            description: 'Michigan Employment & Training Plus, (MET|PLUS)
                         is a 501 (c) 3, Vocational Training non-profit
                         organization that strives to assist Michigan
                         jobseekers with invaluable training and job
                         development that will put them on a career
                         path to success.')

# seed striction to development, for now
if Rails.env.development? # || Rails.env.staging?
  #Company
  200.times do |n|
    ein = Faker::Company.ein
    phone = "(#{(1..9).to_a.shuffle[0..2].join})-#{(1..9).to_a.shuffle[0..2]
             .join}-#{(1..9).to_a.shuffle[0..3].join}"
    email =Faker::Internet.email
    website = Faker::Internet.url
    name = Faker::Company.name
    cmp = Company.new(ein: ein,
                    phone: phone,
                    email: email,
                  website: website,
                     name: name)
    cmp.agencies << agency
    if n < 20
      cmp.status = Company::STATUS[:PND]
    else
      cmp.status = Company::STATUS[:ACT]
    end
    cmp.save!
  end

  companies = Company.all.to_a
  #Address

  200.times do |n|
    street = Faker::Address.street_address
    city = Faker::Address.city
    zipcode = Faker::Address.zip_code
    Address.create(street: street, city: city, zipcode: zipcode,
                   location: companies.pop)
  end

  #JobCategory
  200.times do |n|
    name = FFaker::Job.title
    description = FFaker::Lorem.sentence
    if !JobCategory.create(name: name, description: description)
      JobCategory.create!(name: "#{name}_#{n}", description: description)
    end
  end

  companies = Company.all.to_a
  addresses = Address.all.to_a
  #CompanyPerson
  200.times do |n|
    title = FFaker::Job.title
    email = FFaker::Internet.email
    password = (('a'..'z').to_a + (1..9).to_a).shuffle[0..10].join
    first_name = FFaker::Name.first_name
    last_name = FFaker::Name.last_name
    confirmed_at = DateTime.now
    cp = CompanyPerson.new(title: title, email: email, password: password,
                      first_name: first_name,
                       last_name: last_name,
                    confirmed_at: confirmed_at,
                      company_id: companies.pop.id,
                      address_id: addresses.pop.id,
                          status: 'Active')
    cp.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CA])
    cp.save!
  end

  r = Random.new
  jobcategories = JobCategory.all.to_a
  companypeople = CompanyPerson.all.to_a
  companies = Company.all.to_a
  #job

  200.times do |n|
    title = FFaker::Job.title
    description = Faker::Lorem.paragraph(3,false, 4 )
    shift = ["Day", "Evening", "Morning"][r.rand(3)]
    fulltime =  [false, true][r.rand(2)]
    jobId = ((1..9).to_a + ('A'..'Z').to_a).shuffle[0..7].join
    Job.create(title: title,
               description: description,
               shift: shift,
               company_job_id: jobId ,
               fulltime: fulltime,
               company_id: companies.pop.id,
               company_person_id: companypeople.pop.id,
               job_category_id: jobcategories.pop.id)
  end

  #jobseeker
  jobseekerstatus = JobSeekerStatus.all.to_a
  200.times do |n|
    email = FFaker::Internet.email
    password = (('a'..'z').to_a + (1..9).to_a).shuffle[0..10].join
    first_name = FFaker::Name.first_name
    last_name = FFaker::Name.last_name
    phone = "(#{(1..9).to_a.shuffle[0..2].join})-#{(1..9).to_a.shuffle[0..2]
            .join}-#{(1..9).to_a.shuffle[0..3].join}"
    year_of_birth = 2016 - r.rand(100)
    resume = FFaker::Lorem.word
    job_seeker_status = jobseekerstatus[r.rand(3)]

    JobSeeker.create(first_name: first_name,
                     last_name: last_name,
                     email: email,
                     password: password,
                     year_of_birth: year_of_birth,
                     job_seeker_status: job_seeker_status,
                     resume: resume,
                     phone: phone,
                     confirmed_at: DateTime.now)
  end

  Job.all.to_a.each_with_index do |job, index|
    job.address = Address.all.to_a[index]
  end

  #agency
  addresses = Address.all.to_a
  50.times do |n|
    code = Faker::Code.ean.split(//).shuffle[1..3].join
    angency = agency
    Branch.create(:code => code,
                  agency: angency,
                  address: addresses.pop)
  end

  50.times do |n|
    branch = Branch.create(code: "BR00#{n}", agency: agency)
    branch.address = Address.create!(city: 'Detroit',
              street: "#{n} Main Street", zipcode: 48201)
  end



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


  jobseeker = JobSeeker.create(first_name: 'abc', last_name:'def',
                               email:'vijaya.karumudi1@gmail.com',
                               password:'dfg123',password_confirmation:'dfg123',
                               phone:'345-890-7890',year_of_birth: "1990",
                               confirmed_at: Time.now)


  JobSeeker.create(first_name: 'Mary', last_name: 'McCaffrey',
                        email: 'mary@gmail.com', password: 'qwerty123',
                year_of_birth: '1970', resume: 'text',
            job_seeker_status: @jss2, confirmed_at: Time.now)

  JobSeeker.create(first_name: 'Frank', last_name: 'Williams',
                        email: 'frank@gmail.com', password: 'qwerty123',
                year_of_birth: '1970', resume: 'text',
            job_seeker_status: @jss3, confirmed_at: Time.now)

end

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

# Think we have enough users(JS, AA, JD, CM, CP). We can login in productin env with created creditials.
