module Companies
  class DestroyCompany
    include Authorization::AuthorizationImplementation

    attr_accessor :query

    def initialize(current_user, query_object = nil, job_application_query_object = nil,
      reject_iterator = nil)
      @query = query_object
      @job_application_query_object = job_application_query_object
      @query = Companies::Query.new if @query.nil?
      @job_application_query_object = JobApplications::Query.new \
        if @job_application_query_object.nil?
      @reject_iterator = reject_iterator
      @reject_iterator = JobApplications::Reject.new if @reject_iterator.nil?
      @action = 'destroy'
      @current_user = current_user
    end

    def call(id)
      company = @query.find_by_id(id)
      @action_description = "#{action} #{company.name} agency"
      authorized!(company, @action)

      company.inactive
      @job_application_query_object.find_by_company(company).each do |job_application|
        @reject_iterator.call(job_application, 'Company removed from the system')
      end
      company
    end
  end
end
