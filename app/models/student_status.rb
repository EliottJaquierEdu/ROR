class StudentStatus < ApplicationRecord
  has_many :students
  validates :status, presence: true
end
