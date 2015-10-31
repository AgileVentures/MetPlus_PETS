class User < ActiveRecord::Base
   actable
   validates :email,:email => true,
<<<<<<< HEAD
             :uniqueness => true,
             :presence => true
=======
            :uniqueness => true,
            :presence => true
>>>>>>> development
   validates_presence_of :first_name
   validates_presence_of :last_name
   validates   :phone, :phone => true
end
