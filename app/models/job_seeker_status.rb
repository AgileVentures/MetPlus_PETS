class JobSeekerStatus < ApplicationRecord
  validates_presence_of :description, :short_description

  validates_length_of :short_description, within: 5..25,
                                          too_long: "is too long (maximum is 25 characters)",
                                          too_short: "is too short (minimum is 5 characters)"

  validates_length_of :description, within: 10..255,
                                    too_long: "is too long (maximum is 255 characters)",
                                    too_short: "is too short (minimum is 10 characters)"
end
