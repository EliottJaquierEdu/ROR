class Person < ApplicationRecord
  belongs_to :address

  has_and_belongs_to_many :school_classes
end
