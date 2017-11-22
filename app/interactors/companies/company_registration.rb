module Companies
  class CompanyRegistration
    def approve_company(company)
      company.active
      company.save!

      company_admin = company.company_people[0]

      company_admin.active
      company_admin.approved = true
      company_admin.save

      Event.create(:COMP_APPROVED, company)

      company_admin.user.send_confirmation_instructions
    end
  end
end
