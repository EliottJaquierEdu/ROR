class Student < Person
  belongs_to :student_status, optional: true
  validates :student_status, presence: true, if: -> { self.type == "Student" }

  has_many :grades,
           foreign_key: "person_id",  # Changed from student_id to person_id
           dependent: :destroy
end