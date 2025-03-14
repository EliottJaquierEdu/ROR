class Address < ApplicationRecord
  belongs_to :person
  
  # String representation of an Address
  def to_s
    "#{street} #{number}, #{zip} #{town}"
  end
  
  # JSON representation of an Address
  def as_json(options = {})
    super(options.except(:person))
  end
end
