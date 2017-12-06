require 'ffaker'

# Prevent email validation
class EmailValidator
  # replace method which performs validation using mailgun validator
  def validate_each(_, _, _); end
end

def create_address(location = nil)
  street = Faker::Address.street_address
  city = Faker::Address.city
  state = Faker::Address.state
  zipcode = Faker::Address.zip_code

  if location.nil?
    return Address.create(street: street, city: city, zipcode: zipcode,
                          state: state)
  end
  Address.create(street: street, city: city, zipcode: zipcode, state: state,
                 location: location)
end

def create_email(name_seed)
  name = name_seed.gsub(/[ ,\-']/, '').slice(0, 20).concat('pets')
  Faker::Internet.free_email(name)
end

# --------------------------- Seed Production Database --------------------

puts "\nSeeding Production Data\n\n"

# Create all agency roles
AgencyRole::ROLE.each_value do |agency_role|
  AgencyRole.find_or_create_by!(role: agency_role)
  puts "  Agency role: #{agency_role}"
end

# Create all company roles
CompanyRole::ROLE.each_value do |company_role|
  CompanyRole.find_or_create_by!(role: company_role)
  puts "  Company role: #{company_role}"
end

# Create default Job Types
%w[Full\ Time Part\ Time Internship Contract Salary
   Salary\ &\ Commission Commission\ Only].each do |job_type|
  JobType.find_or_create_by!(job_type: job_type)
  puts "  Job type: #{job_type}"
end

# Create default agency
agency = Agency.find_or_create_by!(name: 'MetPlus', website: 'metplus.org',
                                   phone: '111 222 3333', fax: '333 444 5555',
                                   email: 'pets@metplus.org',
                                   description: 'Michigan Employment & Training Plus,
                          (MET|PLUS) is a 501 (c) 3, Vocational Training
                          non-profit organization that strives to assist
                          Michigan jobseekers with invaluable training
                          and job development that will put them on a
                          career path to success.')
puts '  Default agency: MetPlus'

# Create default Job Shifts
JobShift.find_or_create_by(shift: 'Morning')
JobShift.find_or_create_by(shift: 'Day')
JobShift.find_or_create_by(shift: 'Afternoon')
JobShift.find_or_create_by(shift: 'Midnight')
JobShift.find_or_create_by(shift: 'Swing')

puts '  Job Shifts created'

# Create default Licenses for jobseeker qualification
[
  ['LLMSW', 'LIMITED LICENSE MASTER SOCIAL WORKER'],
  ['LLMSW', 'LIMITED LICENSE MASTER SOCIAL WORKER'],
  ['LMSW', 'LICENSED MASTER SOCIAL WORKER'],
  ['LLPC', 'LIMITED LICENSE PROFESSIONAL COUNSELOR'],
  ['LPC', 'LICENSED PROFESSIONAL COUNSELOR'],
  ['LLBSW', 'LIMITED LICENSE BACHELOR SOCIAL WORKER'],
  ['LBSW', 'LICENSED BACHELOR SOCIAL WORKER'],
  ['FASSW', 'FULL APPROVED SCHOOL SOCIAL WORKER'],
  ['CADC', 'CERTIFIED ALCOHOL DRUG COUNSELOR'],
  ['CAADC', 'CERTIFIED ADVANCED ALCOHOL DRUG COUNSELOR']
].each { |l| License.find_or_create_by(abbr: l[0], title: l[1]) }

puts '  License types created'

# Create default job questions
['Are you authorized to work in the US?',
 'Are you willing to have a background check performed?',
 'Are you willing to take a drug test?'].each do |q|
   Question.find_or_create_by(question_text: q)
 end

puts '  Job questions created'

# Create default education levels
[
  ['High School', 1],
  ['Associates Degree', 2],
  ['Bachelors Degree', 3],
  ['Masters Degree', 4],
  ['PhD', 5],
  ['Other', 6]
].each { |e| Education.find_or_create_by(level: e[0], rank: e[1]) }

puts '  Education levels created'

puts "\nSeeded Production Data"

exit(0) if Rails.env.production?

if Rails.env.development? || Rails.env.staging? || ENV['HEROKU_ENV'] == 'STAGING'

  puts "\nSeeding development/staging data\n\n"

  #-------------------------- Companies -----------------------------------
  50.times do |n|
    ein = Faker::Company.ein
    phone = "(#{(1..9).to_a.sample(3).join})-#{(1..9)
      .to_a.sample(3).join}-#{(1..9).to_a.sample(4).join}"
    name = Faker::Company.name
    website = Faker::Internet.url
    email = create_email(name)
    cmp = Company.new(ein: ein,
                      phone: phone,
                      email: email,
                      job_email: email,
                      website: website,
                      name: name)
    cmp.agencies << agency
    cmp.status = if n < 40
                   'active'
                 else
                   'pending_registration'
                 end
    cmp.save!

    if n < 10
      10.times { create_address(cmp) }
    else
      create_address(cmp)
    end
  end

  # Create a known company for dev/test purposes
  known_company = Company.new(ein: Faker::Company.ein,
                              phone: '111-222-3333',
                              email: 'contact@widgets.com',
                              job_email: 'hr@widgets.com',
                              website: 'www.widgets.com',
                              name: 'Widgets, Inc.',
                              status: 'active')
  known_company.agencies << agency
  known_company.save!

  15.times { create_address(known_company) }

  puts "Companies created: #{Company.count}"

  #-------------------------- Company Addresses ---------------------------

  puts "Company Addresses created: #{Address.count}"

  #-------------------------- Job Categories ------------------------------
  20.times do |n|
    name = FFaker::Job.title
    description = FFaker::Lorem.sentence
    JobCategory.create!(name: "#{name}_#{n}", description: description)
  end

  puts "Job Categories created: #{JobCategory.count}"

  #-------------------------- Company People ------------------------------
  companies = Company.all.to_a
  addresses = Address.all.to_a
  50.times do |n|
    title = FFaker::Job.title
    password = 'secret123'
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email = create_email("#{first_name}#{last_name}")
    confirmed_at = Time.now
    # debugger
    cp = CompanyPerson.new(title: title, email: email, password: password,
                           first_name: first_name,
                           last_name: last_name,
                           confirmed_at: confirmed_at,
                           company_id: companies[n].id,
                           address_id: addresses[n].id,
                           status: 'active')
    cp.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CA])
    cp.save!
  end

  # Create a known company admin for dev/test purposes
  known_company_person = CompanyPerson.new(title: 'HR Director',
                                           email: 'hr@widgets.com',
                                           password: 'qwerty123',
                                           first_name: 'Steve',
                                           last_name: 'Jobs',
                                           confirmed_at: Time.now,
                                           company_id: known_company.id,
                                           address_id: Address.find(1).id,
                                           status: 'active')
  known_company_person.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CA])
  known_company_person.save!

  # Create a known company contact for dev/test purposes
  known_company_contact = CompanyPerson.new(title: 'Treasurer',
                                            email: 'finance@widgets.com',
                                            password: 'qwerty123',
                                            first_name: 'Mya',
                                            last_name: 'Cash',
                                            confirmed_at: Time.now,
                                            company_id: known_company.id,
                                            address_id: Address.find(1).id,
                                            status: 'active')
  known_company_contact.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CC])
  known_company_contact.save!

  # Create more company people for 'known company'
  21.times do |n|
    first_name = FFaker::Name.first_name
    last_name = FFaker::Name.last_name
    cp = CompanyPerson.new(title: FFaker::Job.title,
                           email: create_email("#{first_name}#{last_name}"),
                           password: 'qwerty123',
                           first_name: FFaker::Name.first_name,
                           last_name: FFaker::Name.last_name,
                           phone: FFaker::PhoneNumber.short_phone_number,
                           confirmed_at: Time.now,
                           company_id: known_company.id,
                           address_id: addresses[n].id,
                           status: 'active')
    cp.company_roles << CompanyRole.find_by_role(CompanyRole::ROLE[:CC])
    cp.save!
  end

  puts "Company People created: #{CompanyPerson.count}"

  #-------------------------- Jobs ----------------------------------------
  r = Random.new
  jobcategories = JobCategory.all.to_a
  companypeople = CompanyPerson.all.to_a
  companies = Company.all.to_a
  addresses = Address.all.to_a

  # Create jobs for 'known_company'
  25.times do |n|
    Job.create(title: FFaker::Job.title,
               description: Faker::Lorem.sentence,
               company_job_id: "Job_ID_#{n}",
               company_id: known_company.id,
               company_person_id: known_company_person.id,
               address_id: known_company.addresses[r.rand(15)].id)
  end

  # Create random jobs
  20.times do |n|
    title = FFaker::Job.title
    description = Faker::Lorem.paragraph(3, false, 4)
    job_id = ((1..9).to_a + ('A'..'Z').to_a).sample(8).join
    # debugger
    Job.create(title: title,
               description: description,
               company_job_id: job_id,
               company_id: companies[n].id,
               company_person_id: companypeople[n].id,
               job_category_id: jobcategories[n].id,
               address_id: addresses[n].id)
  end

  puts "Jobs created: #{Job.count}"

  # Rake task to upload generic skills
  Rake::Task['job_skills:import_generic'].invoke

  #-------------------------- Job Seekers ---------------------------------

  @jss1 = JobSeekerStatus.first
  @jss2 = JobSeekerStatus.second
  @jss3 = JobSeekerStatus.third

  # This JobSeeker is used in email previews too :-)
  js1 = JobSeeker.create(first_name: 'Tom', last_name: 'Seeker',
                         email: 'tomseekerpets@gmail.com', password: 'qwerty123',
                         year_of_birth: '1980', phone: '111-222-3333',
                         job_seeker_status: @jss1, confirmed_at: Time.now,
                         address: create_address)

  # Have this JS apply to every other known_company jobs
  Job.where(company: known_company).each do |job|
    if job.id.even?
      job_application = JobApplication.create(job: job, job_seeker: js1)
      Task.new_review_job_application_task job_application, known_company
    end
  end

  # Add resume to this job seeker
  resume = Resume.new(file: File.new('spec/fixtures/files/Admin-Assistant-Resume.pdf'),
                      file_name: 'Admin-Assistant-Resume.pdf',
                      job_seeker_id: js1.id)
  resume.save!

  # Add job applications for this job seeker
  Job.where.not(company: known_company).limit(50).each do |job|
    JobApplication.create!(job: job, job_seeker: js1)
  end

  jobseekerstatus = JobSeekerStatus.all.to_a
  100.times do |_n|
    password = 'secret123'
    first_name = FFaker::Name.first_name
    last_name = FFaker::Name.last_name
    phone = "(#{(1..9).to_a.sample(3).join})-#{(1..9).to_a.sample(3)
      .join}-#{(1..9).to_a.sample(4).join}"
    year_of_birth = 2016 - r.rand(100)
    job_seeker_status = jobseekerstatus[r.rand(3)]

    job_seeker = JobSeeker.create(first_name: first_name,
                                  last_name: last_name,
                                  email: create_email("#{first_name}#{last_name}"),
                                  password: password,
                                  year_of_birth: year_of_birth,
                                  job_seeker_status: job_seeker_status,
                                  phone: phone,
                                  confirmed_at: Time.now,
                                  address: create_address)

    # Add job application for known_company
    job = Job.where(company: known_company)[r.rand(25)]
    job_application = JobApplication.create(job: job, job_seeker: job_seeker)
    Task.new_review_job_application_task job_application, known_company

    # Add resume to some job seekers
    next unless job_seeker.id <= 15
    resume = Resume.create(
      file: File.new('spec/fixtures/files/Admin-Assistant-Resume.pdf'),
      file_name: 'Admin-Assistant-Resume.pdf',
      job_seeker_id: job_seeker.id
    )
  end

  js2 = JobSeeker.create(first_name: 'Mary', last_name: 'McCaffrey',
                         email: 'marymacpets@gmail.com', password: 'qwerty123',
                         year_of_birth: '1970', phone: '111-222-3333',
                         job_seeker_status: @jss2, confirmed_at: Time.now,
                         address: create_address)

  js3 = JobSeeker.create(first_name: 'Frank', last_name: 'Williams',
                         email: 'fwilliamspets@gmail.com', password: 'qwerty123',
                         year_of_birth: '1970', phone: '111-222-3333',
                         job_seeker_status: @jss3, confirmed_at: Time.now,
                         address: create_address)

  js4 = JobSeeker.create(first_name: 'Henry', last_name: 'McCoy',
                         email: 'hmccoypets@gmail.com', password: 'qwerty123',
                         year_of_birth: '1970', phone: '111-222-3333',
                         job_seeker_status: @jss3, confirmed_at: Time.now,
                         address: create_address)

  JobSeeker.create(first_name: 'Mike', last_name: 'Smith',
                   email: 'mike.smith@gmail.com',
                   password: 'qwerty123', password_confirmation: 'qwerty123',
                   year_of_birth: '1990',
                   confirmed_at: Time.now, phone: '111-222-3333',
                   job_seeker_status: @jss1,
                   address: create_address)

  puts "Job Seekers created: #{JobSeeker.count}"

  puts "Job Applications created: #{JobApplication.count}"

  #-------------------------- Agency Branches -----------------------------
  addresses = Address.all.to_a
  10.times do |_n|
    code = Faker::Code.ean.split(//).shuffle[1..3].join
    Branch.create(code: code,
                  agency: agency,
                  address: addresses.pop)
  end

  branch = Branch.create(code: '001', agency: agency)
  branch.address = Address.create!(city: 'Detroit', state: 'Michigan',
                                   street: '123 Main Street', zipcode: 48_201)

  branch = Branch.create(code: '002', agency: agency)
  branch.address = Address.create!(city: 'Detroit', state: 'Michigan',
                                   street: '456 Sullivan Street', zipcode: 48_204)

  branch = Branch.create(code: '003', agency: agency)
  branch.address = Address.create!(city: 'Detroit', state: 'Michigan',
                                   street: '3 Auto Drive', zipcode: 48_206)

  puts "Branches created: #{Branch.count}"

  #-------------------------- Agency People -------------------------------

  agency_aa = AgencyPerson.new(first_name: 'John', last_name: 'Smith',
                               agency_id: agency.id,
                               email: ENV['ADMIN_EMAIL'],
                               password: 'qwerty123', confirmed_at: Time.now,
                               branch_id: agency.branches[0].id,
                               status: 'active')
  agency_aa.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:AA])
  agency_aa.save!

  agency_cm_and_jd = AgencyPerson.new(first_name: 'Chet', last_name: 'Pitts',
                                      agency_id: agency.id, email: 'chet@metplus.org',
                                      password: 'qwerty123', confirmed_at: Time.now,
                                      branch_id: agency.branches[1].id,
                                      status: 'active')
  agency_cm_and_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:CM])
  agency_cm_and_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:JD])
  agency_cm_and_jd.save!

  agency_jd = AgencyPerson.new(first_name: 'Jane', last_name: 'Doe',
                               agency_id: agency.id, email: 'jane@metplus.org',
                               password: 'qwerty123', confirmed_at: Time.now,
                               branch_id: agency.branches[2].id,
                               status: 'active')

  agency_jd.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:JD])
  agency_jd.save!

  agency_cm = AgencyPerson.new(first_name: 'Kevin', last_name: 'Caseman',
                               agency_id: agency.id, email: 'kevin@metplus.org',
                               password: 'qwerty123', confirmed_at: Time.now,
                               branch_id: agency.branches[2].id,
                               status: 'active')

  agency_cm.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[:CM])
  agency_cm.save!

  puts "AgencyPeople created: #{AgencyPerson.count}"

  #-------------------------- Agency Relations ----------------------------
  agency_cm_and_jd.agency_relations <<
    AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:CM]),
                       job_seeker: js1)

  agency_cm_and_jd.agency_relations <<
    AgencyRelation.new(agency_role: AgencyRole.find_by_role(AgencyRole::ROLE[:JD]),
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
  companies = Company.pending_registration

  Task.new_js_unassigned_cm_task(js3, agency)
  Task.new_js_registration_task(js4, agency)
  Task.new_review_company_registration_task(companies[0], agency)
  Task.new_review_company_registration_task(companies[1], agency)
  Task.new_review_company_registration_task(companies[2], agency)
  Task.new_review_company_registration_task(companies[3], agency)

  puts "Tasks created: #{Task.count}"
end
puts "\nDone seeding!"
