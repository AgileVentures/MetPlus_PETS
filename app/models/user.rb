class User < ActiveRecord::Base
   actable
   validates_presence_of :first_name, :last_name, :phone 
   validates_format_of :phone, with:  /\A\(?([0-9]{3})\)?[-|" ".*]?([0-9]{3})[-|" ".*]?([0-9]{4})\z/,
          :message => "phone number should be 619-234-7890 format"
    
end
