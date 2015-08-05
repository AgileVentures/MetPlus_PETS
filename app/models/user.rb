class User < ActiveRecord::Base
  actable

  validates :email, uniqueness: true, presence: true, email: true
  validates :password, presence: true, confirmation: true

  has_secure_password

  before_create :generate_activation_token

  private
    def generate_activation_token
      self.activation_token = (0...16).map { (65 + rand(26)).chr }.join
    end
end
