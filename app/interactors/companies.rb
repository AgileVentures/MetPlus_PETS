module Companies
  class AsJobs < StandardError
    attr_accessor :company
    def initialize(company)
      @company = company
    end
  end
end
