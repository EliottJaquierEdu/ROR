class Person < ApplicationRecord
  self.inheritance_column = :type # Ensures Rails treats "type" as STI

  belongs_to :address

  has_and_belongs_to_many :school_classes
end
