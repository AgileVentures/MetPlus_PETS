module Exceptions
  module User
    class AuthenticationError < StandardError; end
    class UnableToAuthenticate < AuthenticationError; end
    class NotActivated < AuthenticationError; end
    class UserNotFound < AuthenticationError; end
    class NotFound < StandardError; end
  end
end