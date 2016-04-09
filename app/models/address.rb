class Address < ActiveRecord::Base
  belongs_to :location, polymorphic: true
  has_many :jobs 
  validates_presence_of :street
  validates_presence_of :city
  validates_format_of :zipcode, 
    with: /\A\d{5}-\d{4}|\A\d{5}\z/,
    message: 'should be in form of 12345 or 12345-1234',
    allow_blank: true
end
