module JobApplications
  class Query
    def self.find_by_company(company)
      JobApplication.find_by_company(company)
    end
  end
end
