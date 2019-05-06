class License < ApplicationRecord
  has_many :job_licenses, inverse_of: :license
  has_many :jobs, through: :job_licenses, dependent: :destroy

  validates_presence_of   :abbr
  validates_uniqueness_of :abbr, case_sensitive: false

  after_validation { abbr&.upcase! }

  validates_presence_of :title

  def license_description
    "#{abbr} (#{title})"
  end

  def has_job?
    jobs.exists?
  end
end
