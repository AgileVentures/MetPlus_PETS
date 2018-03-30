module Companies
  class DestroyCompany
    include Authorization::AuthorizationImplementation

    attr_accessor :query

    def initialize(current_user, query_object = nil)
      @query = query_object
      @query = Companies::Query.new if @query.nil?
      @action = 'destroy'
      @current_user = current_user
    end

    def call(id)
      company = @query.find_by_id(id)
      @action_description = "#{action} #{company.name} agency"
      is_authorized!(company, @action)

      raise Companies::AsJobs, company if company.jobs.exists?

      @query.destroy(company)
    end
  end
end
