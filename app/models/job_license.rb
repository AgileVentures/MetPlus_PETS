class JobLicense < ApplicationRecord
  belongs_to :job, inverse_of: :job_licenses
  belongs_to :license
end
