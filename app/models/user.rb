class User < ActiveRecord::Base
  actable

  validates :email, :email => true,
                    :uniqueness => true,
                    :presence => true

  validates :password, :length => {minimum: 8}

  has_secure_password

  before_create :generate_activation_token
  private
    def generate_activation_token
      self.activation_token = (0...16).map { (65 + rand(26)).chr }.join
    end
end
