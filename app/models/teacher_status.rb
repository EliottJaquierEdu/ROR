class TeacherStatus < ApplicationRecord
  has_many :teachers, class_name: 'Person', foreign_key: 'teacher_status_id'
  validates :status, presence: true
  
  # String representation of a TeacherStatus
  def to_s
    status
  end
  
  # JSON representation of a TeacherStatus
  def as_json(options = {})
    super(options.merge(
      methods: [:teacher_count]
    ))
  end
  
  # Helper method to get the number of teachers with this status
  def teacher_count
    teachers.count
  end
end
