class Room < ApplicationRecord
  has_many :school_classes

  validates :name, presence: true, uniqueness: true
  
  # String representation of a Room
  def to_s
    name
  end
  
  # JSON representation of a Room
  def as_json(options = {})
    super(options.merge(
      methods: [:class_count]
    ))
  end
  
  # Helper method to get the number of classes
  def class_count
    school_classes.count
  end
end
