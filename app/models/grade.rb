class Grade < ApplicationRecord
  belongs_to :student, class_name: "Person", foreign_key: "student_id"
  belongs_to :examination

  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :effective_date, presence: true
end
