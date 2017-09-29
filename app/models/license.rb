class License < ActiveRecord::Base
  has_and_belongs_to_many :jobs

  def license_description
    "#{abbr} (#{title})"
  end
end
