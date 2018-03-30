module Companies
  class Query
    def find_by_id(id)
      Company.find_by_id(id)
    end

    def destroy(company)
      company.destroy
      company
    end
  end
end
