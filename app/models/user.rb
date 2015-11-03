class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable,:validatable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :validatable
   actable
   validates :email,:email => true,
             :uniqueness => true,
             :presence => true
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates :password, :length => {minimum: 8}, :if => :password 
   validates   :phone, :phone => true
end
