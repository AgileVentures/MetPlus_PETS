class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :validatable
   actable
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
end
