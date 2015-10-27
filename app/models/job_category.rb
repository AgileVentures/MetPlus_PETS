class JobCategory < ActiveRecord::Base
 has_many   :jobs
 has_and_belongs_to_many:skills

 validates_presence_of :name
 validates_presence_of :description

end
