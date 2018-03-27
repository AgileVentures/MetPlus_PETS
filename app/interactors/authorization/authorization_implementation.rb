module Authorization
  module AuthorizationImplementation
    include Pundit
    attr_accessor :action_desc, :action, :current_user

    def authorized?(record, query)
      authorized!(record, query)
    rescue Authorization::NotAuthorizedError
      false
    end

    def authorized!(record, query)
      authorize(record, query + '?')
    rescue Pundit::NotAuthorizedError => exception
      user_not_authorized(exception)
    end

    protected

    def action_description
      @action_desc
    end

    def action_description=(description)
      @action_desc = description.delete('?')
    end

    private

    def user_not_authorized(exception)
      query = exception.query.delete('?')
      raise Authorization::NotAuthorizedError,
            query: query,
            record: exception.record,
            policy: exception.policy,
            action_description: action_description
    end
  end
end
