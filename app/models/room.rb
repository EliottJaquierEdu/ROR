class Room < ApplicationRecord
  has_many :school_classes

  validates :name, presence: true, uniqueness: true
end
