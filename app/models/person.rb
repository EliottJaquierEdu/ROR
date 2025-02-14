class Person < ApplicationRecord
  self.inheritance_column = :type # Ensures Rails treats "type" as STI

  belongs_to :status
  belongs_to :address

  has_and_belongs_to_many :scool_classes

  enum role: { student: 0, teacher: 1 }
end
