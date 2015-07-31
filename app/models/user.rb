class User < ActiveRecord::Base
  actable

  validates :email, uniqueness: true, presence: true, email: true
  validates :password, presence: true, confirmation: true

  has_secure_password

end
