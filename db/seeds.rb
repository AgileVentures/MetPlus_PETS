require 'ffaker'

# --------------------------- Seed Production Database --------------------

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

# Create all agency roles
AgencyRole::ROLE.each_value do |agency_role|
  AgencyRole.create(role: agency_role)
end

# Create all company roles
CompanyRole::ROLE.each_value do |company_role|
  CompanyRole.create(role: company_role)
end

# Create default agency
agency = Agency.create!(name: 'MetPlus', website: 'metplus.org',
            phone: '111 222 3333', fax: '333 444 5555',
            email: 'pets@metplus.org',
            description: 'Michigan Employment & Training Plus, (MET|PLUS)
                         is a 501 (c) 3, Vocational Training non-profit
                         organization that strives to assist Michigan
                         jobseekers with invaluable training and job
                         development that will put them on a career
                         path to success.')

puts "\nSeeded Production Data"

puts "\nSeeding development DB"

# seed striction to development, for now
if Rails.env.development? || Rails.env.staging?

  #-------------------------- Companies -----------------------------------
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

  puts "Companies created: #{Company.count}"

  #-------------------------- Company Addresses ---------------------------
  companies = Company.all.to_a
  200.times do |n|
    street = Faker::Address.street_address
    city = Faker::Address.city
    state = Faker::Address.state
    zipcode = Faker::Address.zip_code
    Address.create(street: street, city: city, zipcode: zipcode, state: state,
                   location: companies.pop)
  end

  puts "Company Addresses created: #{Address.count}"

  #-------------------------- Job Categories ------------------------------
  200.times do |n|
    name = FFaker::Job.title
    description = FFaker::Lorem.sentence
    JobCategory.create!(name: "#{name}_#{n}", description: description)

  end

  puts "Job Categories created: #{JobCategory.count}"

  #-------------------------- Skills --------------------------------------
  30.times do |n|
    Skill.create(name: FFaker::Skill.specialty,
                 description: FFaker::Lorem.sentence)
  end

  puts "Skills created: #{Skill.count}"

  #-------------------------- Company People ------------------------------
  companies = Company.all.to_a
  addresses = Address.all.to_a
  200.times do |n|
    title = FFaker::Job.title
    email = FFaker::Internet.email
    password = "secret123"
    first_name = FFaker::Name.first_name
    last_name = FFaker::Name.last_name
    confirmed_at = DateTime.now
    cp = CompanyPerson.new(title: title, email: email, password: password,
                      first_name: first_name,
                       last_name: last_name,
                    confirmed_at: confirmed_at,
                      company_id: companies[n].id,
                      address_id: addresses[n].id,
                          status: 'Active')
    cp.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CA])
    cp.save!
  end
  puts "Company People created: #{CompanyPerson.count}"

  #-------------------------- Jobs ----------------------------------------
  r = Random.new
  jobcategories = JobCategory.all.to_a
  companypeople = CompanyPerson.all.to_a
  companies = Company.all.to_a
  addresses = Address.all.to_a 
  #job
  200.times do |n|
    title = FFaker::Job.title
    description = Faker::Lorem.paragraph(3,false, 4 )
    shift = ["Day", "Evening", "Morning"][r.rand(3)]
    fulltime =  [false, true][r.rand(2)]
    jobId = ((1..9).to_a + ('A'..'Z').to_a).shuffle[0..7].join
    job =Job.create(title: title,
               description: description,
               shift: shift,
               company_job_id: jobId ,
               fulltime: fulltime,
               company_id: companies[n].id,
               company_person_id: companypeople[n].id,
               job_category_id: jobcategories[n].id,
               address_id: addresses[n].id)
     
 
  end

  puts "Jobs created: #{Job.count}"

  #-------------------------- Job Seekers ---------------------------------
  jobseekerstatus = JobSeekerStatus.all.to_a
  200.times do |n|
    email = FFaker::Internet.email
    password = "secret123"
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

  js4 = JobSeeker.create(first_name: 'Henry', last_name: 'McCoy',
                        email: 'henry@gmail.com', password: 'qwerty123',
                year_of_birth: '1970', resume: 'text',
            job_seeker_status: @jss3, confirmed_at: Time.now)


  JobSeeker.create(first_name: 'abc', last_name:'def',
                               email:'vijaya.karumudi1@gmail.com',
                               password:'dfg123',password_confirmation:'dfg123',
                               phone:'345-890-7890',year_of_birth: "1990",
                               confirmed_at: Time.now,
                               job_seeker_status: @jss1)

  puts "Job Seekers created: #{JobSeeker.count}"

  #-------------------------- Agency Branches -----------------------------
  addresses = Address.all.to_a
  50.times do |n|
    code = Faker::Code.ean.split(//).shuffle[1..3].join
    Branch.create(:code => code,
                  agency: agency,
                  address: addresses.pop)
  end

  branch = Branch.create(code: '001', agency: agency)
  branch.address = Address.create!(city: 'Detroit', state: "MI",
              street: '123 Main Street', zipcode: 48201)

  branch = Branch.create(code: '002', agency: agency)
  branch.address = Address.create!(city: 'Detroit',state: "MI",
              street: '456 Sullivan Street', zipcode: 48204)

  branch = Branch.create(code: '003', agency: agency)
  branch.address = Address.create!(city: 'Detroit',state: "MI",
              street: '3 Auto Drive', zipcode: 48206)

  puts "Branches created: #{Branch.count}"

  #-------------------------- Agency People -------------------------------

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

  agency_jd = AgencyPerson.new(first_name: 'Jane', last_name: 'Doe',
                        agency_id: agency.id, email: 'jane@metplus.org',
                        password: 'qwerty123', confirmed_at: Time.now,

                        branch_id: agency.branches[2].id,
                        status: AgencyPerson::STATUS[:ACT])

  agency_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:JD])
  agency_jd.save!

  puts "AgencyPeople created: #{AgencyPerson.count}"

  #-------------------------- Agency Relations ----------------------------
  agency_cm_and_jd.agency_relations <<
        AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:CM]),
                            job_seeker: js1)
  agency_cm_and_jd.agency_relations <<
        AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:JD]),
                            job_seeker: js2)
  agency_cm_and_jd.save!

  agency_jd.agency_relations <<
        AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:JD]),
                            job_seeker: js3)
  agency_jd.save!

  puts "Agency Relations created: #{AgencyRelation.count}"

  #-------------------------- Tasks ---------------------------------------
  companies = Company.where(status: Company::STATUS[:PND])

  Task.new_js_unassigned_cm_task(js3, agency)
  Task.new_js_registration_task(js4, agency)
  Task.new_review_company_registration_task(companies[0], agency)
  Task.new_review_company_registration_task(companies[1], agency)
  Task.new_review_company_registration_task(companies[2], agency)
  Task.new_review_company_registration_task(companies[3], agency)

  puts "Tasks created: #{Task.count}"
end

# Think we have enough users(JS, AA, JD, CM, CP). We can login in productin env with created creditials.
puts "\nDone seeding!"
