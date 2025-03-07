class TeachersStatus < ApplicationRecord
  has_many :teacher
  validates :status, presence: true
end