class JobLicense < ActiveRecord::Base
  belongs_to :job
  belongs_to :license
end
