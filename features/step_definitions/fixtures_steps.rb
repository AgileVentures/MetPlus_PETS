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
    company.save
  end
end

Given(/^the following agency people exist:$/) do |table|
  table.hashes.each do |hash|
    agency_name = hash.delete 'agency'
    hash['agency_id'] = Agency.find_by_name(agency_name).id

    agency_role_id = hash.delete 'role'
    agency_role = AgencyRole.find_by_role(AgencyRole::ROLE[agency_role_id.to_sym])

    hash['password_confirmation'] = hash['password']
    hash['confirmed_at'] = Time.now

    agency_person = AgencyPerson.new(hash)
    agency_person.agency_roles << agency_role
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
    jobseeker.save
  end
end

Given(/^the following job categories exist:$/) do |table|
  table.hashes.each do |hash|
    JobCategory.create!(hash)
  end
end
