class Grade < ApplicationRecord
  include Archivable

  belongs_to :student,
             class_name: "Person",
             foreign_key: "person_id"
  belongs_to :examination

  validates :value, presence: true,
            numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 6.0 }

  validates :effective_date, presence: true
  validates :student, presence: true
  validate :student_must_be_student

  # String representation of a Grade
  def to_s
    "Grade #{value} for #{student&.full_name} on #{examination&.title}"
  end

  # JSON representation of a Grade
  def as_json(options = {})
    super(options.merge(
      include: {
        examination: { only: [:id, :title] },
        student: { only: [:id, :firstname, :lastname], methods: [:full_name] }
      }
    ))
  end

  private

  def student_must_be_student
    if student.present? && student.type != 'Student'
      errors.add(:student, "must be a student")
    end
  end
end
