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

  private
    def generate_activation_token
      self.activation_token = self.id.to_s + (0...16).map { (65 + rand(26)).chr }.join
      save
    end
    def after_creation
      generate_activation_token
      UserMailer.activation(self).deliver_now
    end
end
