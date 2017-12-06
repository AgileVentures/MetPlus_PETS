module Companies
  class DenyCompanyRegistration
    def call(company, reason)
      deny_company(company)
      create_denied_event(company, reason)
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

    def deny_company(company)
      company.registration_denied
      company.company_people[0].company_denied
      company.save
    end

    def create_denied_event(company, reason)
      obj = Struct.new(:company, :reason)
      Event.create(:COMP_DENIED, obj.new(company, reason))
    end
  end
end
