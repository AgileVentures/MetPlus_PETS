FactoryGirl.define do
  factory :agency_person do
    agency
    branch
    user
    status 'active'
  end

  factory :agency_admin, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles {[AgencyRole.find_by_role(AgencyRole::ROLE[:AA]) || FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:AA])]}
  end

  factory :job_developer, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles {[AgencyRole.find_by_role(AgencyRole::ROLE[:JD]) || FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])]}
  end

  factory :case_manager, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles {[AgencyRole.find_by_role(AgencyRole::ROLE[:CM]) || FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM])]}
  end

  factory :jd_cm, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles {[AgencyRole.find_by_role(AgencyRole::ROLE[:CM]) || FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:CM]),
                   AgencyRole.find_by_role(AgencyRole::ROLE[:JD]) || FactoryGirl.create(:agency_role, role: AgencyRole::ROLE[:JD])]}
  end
end
