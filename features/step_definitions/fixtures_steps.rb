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

Given(/^the following agencies exist:$/) do |table|
  table.hashes.each do |hash|
    Agency.create!(hash)
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

Given(/^the following agency branches exist:$/) do |table|
  table.hashes.each do |hash|
    agency_name = hash.delete 'agency'
    agency = Agency.find_by_name(agency_name)
    branch_code = hash.delete 'code'
    branch = Branch.create(code: branch_code, agency: agency)
    branch.address = Address.create!(hash)
  end
end