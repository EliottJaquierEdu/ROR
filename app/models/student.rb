class Student < Person
  belongs_to :student_status

  has_many :grades, foreign_key: "student_id", dependent: :destroy
end
