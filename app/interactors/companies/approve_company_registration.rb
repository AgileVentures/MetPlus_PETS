module Companies
  class ApproveCompanyRegistration
    def call(company)
      company.active
      company.save!

      company_admin = company.company_people[0]

      company_admin.active
      company_admin.approved = true
      company_admin.save

      Event.create(:COMP_APPROVED, company)

      company_admin.user.send_confirmation_instructions

      close_tasks(company)
    end

    private

    def close_tasks(company)
      Task.find_by_type_and_target_company_open('company_registration', company)
          .each do |task|
        task.force_close
        task.save!
      end
    end
  end
end
