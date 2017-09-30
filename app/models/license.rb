class License < ActiveRecord::Base
  has_many :job_licenses, dependent: :destroy
  has_many :jobs, through: :job_licenses

  def license_description
    "#{abbr} (#{title})"
  end
end
