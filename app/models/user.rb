class User < ActiveRecord::Base
   actable
   validates_presence_of :first_name, :last_name, :phone 
   validate :phone 
end
