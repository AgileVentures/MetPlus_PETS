class User < ActiveRecord::Base
   has_one :pets_account
   actable
   validates:email,:email => true,
            :uniqueness => true,
            :presence => true
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
    
end
