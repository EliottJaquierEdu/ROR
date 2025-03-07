class Grade < ApplicationRecord
  belongs_to :student,
             class_name: "Person",
             foreign_key: "person_id"
  belongs_to :examination

  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }

  validates :effective_date, presence: true
  validates :student, presence: true
  validate :student_must_be_student

  private

  def student_must_be_student
    if student.present? && student.type != 'Student'
      errors.add(:student, "must be a student")
    end
  end
end
