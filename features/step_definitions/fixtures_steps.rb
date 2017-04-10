Given(/^the following (.+) records:$/) do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end
end

Given(/^the following agency roles exist:$/) do |table|
  table.hashes.each do |hash|
    hash['role'] = AgencyRole::ROLE[hash['role'].to_sym]
    AgencyRole.create!(hash)
  end
end

Given(/^the following company roles exist:$/) do |table|
  table.hashes.each do |hash|
    hash['role'] = CompanyRole::ROLE[hash['role'].to_sym]
    CompanyRole.create!(hash)
  end
end

Given(/^the following agencies exist:$/) do |table|
  table.hashes.each do |hash|
    Agency.create!(hash)
  end
end

Given(/^the following companies exist:$/) do |table|
  table.hashes.each do |hash|
    agency_name = hash.delete 'agency'
    company = Company.new(hash)
    company.agencies << Agency.find_by_name(agency_name)
    company.save!
  end
end

Given(/^the following agency people exist:$/) do |table|
  @all_agency_people = {}

  table.hashes.each do |hash|
    agency_name = hash.delete 'agency'
    hash['agency_id'] = Agency.find_by_name(agency_name).id

    hash['password_confirmation'] = hash['password']
    hash['confirmed_at'] = Time.now
    roles = hash.delete('role').split(/,/)

    agency_person = AgencyPerson.new(hash)

    roles.each do |role|
      agency_person.agency_roles << AgencyRole.find_by_role(AgencyRole::ROLE[role.to_sym])
    end

    agency_person.save

    email = hash['email']
    @all_agency_people[email] = agency_person
  end
end

Given(/^the following agency relations exist:$/) do |table|
  table.hashes.each do |hash|
    job_seeker    = User.find_by_email(hash['job_seeker']).actable
    agency_person = User.find_by_email(hash['agency_person']).actable
    if hash['role'] == 'JD'
      job_seeker.assign_job_developer agency_person, agency_person.agency
    else
      job_seeker.assign_case_manager agency_person, agency_person.agency
    end
  end
end

Given(/^the following company people exist:$/) do |table|
  table.hashes.each do |hash|
    company_name = hash.delete 'company'
    hash['company_id'] = Company.find_by_name(company_name).id

    company_role_id = hash.delete 'role'
    company_role = CompanyRole.find_by_role(CompanyRole::ROLE[company_role_id.to_sym])

    hash['password_confirmation'] = hash['password']
    hash['confirmed_at'] = Time.now

    company_person = CompanyPerson.new(hash)
    company_person.company_roles << company_role
    company_person.save
  end
end

Given(/^the following company addresses exist:$/) do |table|
  table.hashes.each do |hash|
    company = Company.find_by_name(hash.delete('company'))
    company.addresses << Address.create!(hash)
  end
end

Given(/^the following agency branches exist:$/) do |table|
  table.hashes.each do |hash|
    agency_name = hash.delete 'agency'
    agency = Agency.find_by_name(agency_name)
    branch_code = hash.delete 'code'
    branch = Branch.create(code: branch_code, agency: agency)
    branch.address = Address.create!(hash)
  end
end

Given(/^the following jobseekerstatus values exist:$/) do |table|
  table.hashes.each do |hash|
    JobSeekerStatus.create!(hash)
  end
end

# Given(/^the following jobseeker(?:s?) exist:$/) do |table|
#   table.hashes.each do |hash|
#     jobseeker = hash.delete 'jobseeker'
#     hash['actable_type'] = 'JobSeeker'
#     hash['password_confirmation'] = hash['password']
#     hash['confirmed_at'] = Time.now
#     seeker_status = hash.delete 'job_seeker_status'
#     job_seeker_status = JobSeekerStatus.find_by_short_description(seeker_status)
#     jobseeker = JobSeeker.new(hash)
#     jobseeker.job_seeker_status = job_seeker_status
#     jobseeker.address = FactoryGirl.create(:address)
#     jobseeker.save!
#   end
# end

Given(/^the following jobseekers exist:$/) do |table|
  @all_job_seekers = {}

  table.hashes.each do |hash|
    address = Address.create(street: Faker::Address.street_address,
      city: Faker::Address.city, 
      zipcode: Faker::Address.zip_code,
      state: Faker::Address.state)

    job_seeker_status = JobSeekerStatus.find_or_create_by(
      short_description: hash['job_seeker_status']) do |status|
      status.short_description = hash['job_seeker_status'],
      status.description = hash['job_seeker_status']
    end

    email = hash['email']
    # job_seeker_status.job_seekers << JobSeeker.create(first_name: hash['first_name'], 
    #     last_name: hash['last_name'],
    #     email: email, 
    #     password: hash['password'],
    #     password_confirmation: hash['password_confirmation'],
    #     year_of_birth: hash['year_of_birth'], 
    #     phone: hash['phone'],
    #     confirmed_at: Time.now,
    #     address: address
    #   )
    # @all_job_seekers[email] = job_seeker_status.job_seekers.last
    @all_job_seekers[email] = JobSeeker.create(first_name: hash['first_name'], 
        last_name: hash['last_name'],
        email: email, 
        password: hash['password'],
        password_confirmation: hash['password_confirmation'],
        year_of_birth: hash['year_of_birth'], 
        phone: hash['phone'],
        confirmed_at: Time.now,
        address: address,
        job_seeker_status_id: job_seeker_status.id
      )
  end
end

Given(/^the following job categories exist:$/) do |table|
  table.hashes.each do |hash|
    JobCategory.create!(hash)
  end
end

Given(/^the following job skills exist:$/) do |table|
  table.hashes.each do |hash|
    Skill.create!(hash)
  end
end

Given(/^the following tasks exist:$/) do |table|
  table.hashes.each do |hash|
    task_attributes = {
      task_type: hash['task_type'].to_sym,
      status: Task::STATUS[hash['status'].to_sym],
      deferred_date: Date.parse(hash['deferred_date'])
    }
    task = FactoryGirl.build(:task, task_attributes)

    owner = hash['owner'].split(',')
    if owner.count == 1
      task.task_owner = {:user => User.find_by_email(owner.first).pets_user}
    else
      role = owner.last.to_sym

      agency = Agency.find_by_name(owner.first)
      if agency.nil?
        company = Company.find_by_name(owner.first)
        task.task_owner = {:company => {company: company, role: role}}
      else
        task.task_owner = {:agency => {agency: agency, role: role}}
      end
    end

    targets = hash['targets']
    if targets =~ /@/
      @all_job_seekers ||= {}
      task.target = @all_job_seekers[targets] || User.find_by_email(targets)
    else
      task.target = Company.find_by_name targets
    end

    task.save!
  end
end

Given(/^the following resumes exist:$/) do |table|
  table.hashes.each do |hash|
    job_seeker = JobSeeker.find_by(email: hash[:job_seeker])
    resume = FactoryGirl.create(:resume,
                                file_name: hash[:file_name],
                                job_seeker: job_seeker)
  end
end

Given(/^the following jobs exist:$/) do |table|
  table.hashes.each do |hash|
    company_name  = hash.delete 'company'
    creator_email = hash.delete 'creator'
    skills = hash.delete 'skills'
    city = hash.delete 'city'

    job = Job.new(hash.merge(company_job_id: 'JOBID'))

    job.company = Company.find_by_name company_name
    job.company_person = User.find_by_email(creator_email).pets_user if
      creator_email

    job.address = FactoryGirl.create(:address,
                                     city: city,
                                     location: job.company) unless city.blank?

    job.save!
    unless skills.blank?
      skills.split(/(?:,\s*)/).each do |skill|
        JobSkill.create(job: job, skill: Skill.find_by_name(skill),
                        required: true, min_years: 1, max_years: 20)
      end
    end
  end
end

And /^I create the following jobs$/ do |table|
  step "the following jobs exist:", table
end

Given(/^the following job applications exist:$/) do |table|
  table.hashes.each do |hash|
    job = Job.find_by_title(hash['job title'])
    job_seeker = User.find_by_email(hash['job seeker']).actable

    unless hash[:status]
      JobApplication.create!(job: job, job_seeker: job_seeker)
    else
      FactoryGirl.create(:job_application, job: job, job_seeker: job_seeker,
                         status: hash[:status])
    end
  end
end

Given(/^the default settings are present$/) do
  [
    { :short_description => 'Unemployed Seeking',
      :description => 'A jobseeker Without any work and looking for a job.'},
    { :short_description => 'Employed Looking',
      :description => 'A jobseeker with a job and looking for a job.'},
    { :short_description => 'Employed Not Looking',
      :description => 'A jobseeker with a job and not looking for a job for now.'}
  ].each do |values|
    JobSeekerStatus.create(values)
  end
  step "the following agency roles exist:", table(%{
    | role  |
    | AA    |
    | CM    |
    | JD    |
  })
  step "the following agencies exist:", table(%{
  | name    | website     | phone        | email                  | fax          |
  | MetPlus | metplus.org | 555-111-2222 | pets_admin@metplus.org | 617-555-1212 |
  })
  step "the following company roles exist:", table(%{
    | role  |
    | CA    |
    | CC    |
  })
end

Given(/^the following company registration exist:$/) do |table|  
  table.hashes.each do |hash|
    cmp = Company.create(ein: hash['ein'],
                         phone: '222-333-4567',
                         email: 'contact@ymail.com',
                         job_email: 'jobs@ymail.com',
                         website: 'www.widgets.com',
                         name: hash['company name'],
                         status: 0)
    cmp.assign_attributes({
      "addresses_attributes"=>{
        "0"=>{ "street"=>"12 Main Street", 
               "city"=>"Detroit", 
               "state"=>"Michigan", 
               "zipcode"=>"02034" }
      }, 
      "company_people_attributes"=>{
        "0"=>{ "first_name"=>"#{hash['first_name']}", 
               "last_name"=>"#{hash['last_name']}", 
               "title"=>"#{hash['title']}", 
               "phone"=>"#{hash['contact']}", 
               "email"=>"#{hash['email']}",
               "password" => "qwerty123",
               "password_confirmation" => "qwerty123" } 
        }
      })
    cmp_person = cmp.company_people[0]
    cmp_person.company_roles << CompanyRole.create!(role: CompanyRole::ROLE[:CA])
    cmp_person_user = cmp.company_people[0].user
    cmp_person.skip_confirmation_notification!
    cmp_person.approved = false
    cmp.agencies << Agency.first
    cmp.save!
    Task.new_review_company_registration_task(cmp, cmp.agencies[0])
  end
end
