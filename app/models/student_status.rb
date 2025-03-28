class StudentStatus < ApplicationRecord
  has_many :students
  has_many :people
  validates :status, presence: true
  
  # String representation of a StudentStatus
  def to_s
    status
  end
  
  # JSON representation of a StudentStatus
  def as_json(options = {})
    super(options.merge(
      methods: [:student_count]
    ))
  end
  
  # Helper method to get the number of students with this status
  def student_count
    students.count
  end
end
