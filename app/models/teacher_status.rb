class TeacherStatus < ApplicationRecord
  has_many :teachers, class_name: 'Person', foreign_key: 'teacher_status_id'
  validates :status, presence: true
end
