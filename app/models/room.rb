class Room < ApplicationRecord
  has_many :scool_classes

  validates :name, presence: true, uniqueness: true
end
