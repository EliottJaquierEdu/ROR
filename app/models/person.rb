class Person < ApplicationRecord
  has_one :address
  accepts_nested_attributes_for :address, allow_destroy: true

  has_and_belongs_to_many :school_classes

  def full_name
    "#{firstname} #{lastname}"
  end
end
