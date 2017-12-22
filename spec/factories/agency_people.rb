FactoryBot.define do
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
    agency_roles do
      [
        AgencyRole.find_by_role(AgencyRole::ROLE[:AA]) ||
          FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:AA])
      ]
    end
  end

  factory :job_developer, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles do
      [
        AgencyRole.find_by_role(AgencyRole::ROLE[:JD]) ||
          FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD])
      ]
    end
  end

  factory :case_manager, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles do
      [
        AgencyRole.find_by_role(AgencyRole::ROLE[:CM]) ||
          FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:CM])
      ]
    end
  end

  factory :jd_cm, class: AgencyPerson do
    agency
    branch
    user
    status 'active'
    agency_roles do
      [
        AgencyRole.find_by_role(AgencyRole::ROLE[:CM]) ||
          FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:CM]),
        AgencyRole.find_by_role(AgencyRole::ROLE[:JD]) ||
          FactoryBot.create(:agency_role, role: AgencyRole::ROLE[:JD])
      ]
    end
  end
end
