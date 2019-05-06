class User < ApplicationRecord
  include Users::RoleModule
  include Users::Types

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable,
         :validatable
  actable
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates   :phone, phone: true
  validates   :email, email: true

  def full_name(order = { last_name_first: true })
    return "#{last_name}, #{first_name}" if order[:last_name_first]

    "#{first_name} #{last_name}"
  end

  # Devise controller method overrides ...
  # ...see: https://github.com/plataformatec/devise/wiki/
  #             How-To:-Require-admin-to-activate-account-before-sign_in

  def active_for_authentication?
    super && approved? && pets_user.can_login?
  end

  def can_login?
    true
  end

  def inactive_message
    if !approved? && pets_user.try(:company_pending?)
      :signed_up_but_not_approved
    elsif !approved? && pets_user.try(:company_denied?)
      :not_approved
    elsif pets_user.respond_to?('company') && pets_user.company&.try(:inactive?)
      :company_no_longer_active
    else
      super
    end
  end
end
