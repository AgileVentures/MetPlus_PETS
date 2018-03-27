module Authorization
  class NotAuthorizedError < StandardError
    attr_reader :query, :record, :policy, :action_description

    def initialize(options = {})
      message = if options.is_a? String
                  options
                else
                  initialize_from_hash(options)
                end

      super(message)
    end

    private

    def initialize_from_hash(options)
      @query  = options[:query]
      @record = options[:record]
      @policy = options[:policy]
      @action_description = options[:action_description]

      options.fetch(:message) do
        "not allowed to #{query} this #{record.inspect}"
      end
    end
  end
end
