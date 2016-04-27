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

Given(/^the following jobseeker exist:$/) do |table|
  table.hashes.each do |hash|
    jobseeker = hash.delete 'jobseeker'
    hash['actable_type'] = 'JobSeeker'
    hash['password_confirmation'] = hash['password']
    hash['confirmed_at'] = Time.now
    seeker_status = hash.delete 'job_seeker_status'
    job_seeker_status = JobSeekerStatus.find_by_value(seeker_status)
    jobseeker = JobSeeker.new(hash)
    jobseeker.job_seeker_status = job_seeker_status
    jobseeker.address = FactoryGirl.create(:address)
    jobseeker.save
  end
end

Given(/^the following job categories exist:$/) do |table|
  table.hashes.each do |hash|
    JobCategory.create!(hash)
  end
end

Given(/^the following tasks exist:$/) do |table|
  table.hashes.each do |hash|

    owner = hash.delete 'owner'
    targets = hash.delete 'targets'
    hash['task_type'] = hash['task_type'].to_sym
    hash['status'] = Task::STATUS[hash['status'].to_sym]
    hash['deferred_date'] = Date.parse(hash.delete 'deferred_date')

    task = FactoryGirl.build(:task, hash)

    if owner =~ /,/
      agency = Agency.find_by_name(owner.split(/,/)[0])
      role = owner.split(/,/)[1]
      if agency.nil?
        company = Company.find_by_name(owner.split(/,/)[0])
        task.task_owner = {:company => {company: company, role: role.to_sym}}
      else
        task.task_owner = {:agency => {agency: agency, role: role.to_sym}}
      end
    else
      task.task_owner = {:user => User.find_by_email(owner).pets_user}
    end
    if targets =~ /@/
      task.target = User.find_by_email targets
    end
    task.save!
  end
end


Given(/^the following jobs exist:$/) do |table|
  table.hashes.each do |hash|

    company_name  = hash.delete 'company'
    creator_email = hash.delete 'creator'

    job = FactoryGirl.build(:job, hash)

    job.company = Company.find_by_name company_name
    job.company_person = User.find_by_email(creator_email).pets_user

    job.save!
  end
end