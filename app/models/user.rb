require 'exceptions'
class User < ActiveRecord::Base
  actable

  validates :email, :email => true,
                    :uniqueness => true,
                    :presence => true

  validates :password, :length => {minimum: 8}

  has_secure_password

  after_create :after_creation

  def activated?
    self.activation_token == nil
  end

  def activate(token)
    if token == activation_token
      self.activation_token = nil
      return true if save
    end
    false
  end

  def self.find_by_activation_token token
    user = User.find_by_id(token[0..-User.token_size])
    if user != nil and user.activation_token != nil
      return user
    end
    return nil
  end

  def self.login!(email, password)
    user = User.find_by_email(email)
    if user == nil
      raise Exceptions::User::UserNotFound.new 'Unable to find user'
    elsif !user.activated?
      raise Exceptions::User::NotActivated.new 'User is not activated'
    elsif !user.authenticate(password)
      raise Exceptions::User::UnableToAuthenticate.new 'Email and password do not match'
    end
    user
  end

  private
    def self.token_size
      16
    end
    def generate_activation_token
      self.activation_token = self.id.to_s + (0...User.token_size).map { (65 + rand(26)).chr }.join
      save
    end
    def after_creation
      generate_activation_token
      UserMailer.activation(self).deliver_now
    end
end
