class User < ActiveRecord::Base
   actable
   validates:email,:email => true,
            :uniqueness => true,
            :presence => true
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
   
   def admin?
     self.administrator
   end
end
