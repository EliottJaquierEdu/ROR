class Room < ApplicationRecord
  has_many :classrooms

  validates :name, presence: true, uniqueness: true
end
