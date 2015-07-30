class User < ActiveRecord::Base
  validates :email, uniqueness: true, presence: true, email: true
  validates :password, presence: true, confirmation: true

  has_secure_password

end
