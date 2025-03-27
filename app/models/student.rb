class Student < Person
  include Gradeable

  belongs_to :student_status, optional: true
  validates :student_status, presence: true, if: -> { self.type == "Student" }

  has_many :grades,
           foreign_key: "person_id",  # Changed from student_id to person_id
           dependent: :destroy

  # String representation of a Student
  def to_s
    "Student: #{full_name}"
  end

  # JSON representation of a Student
  def as_json(options = {})
    super(options.merge(
      include: { student_status: { only: [:id, :status] } }
    ))
  end

  def load_show_data(selected_week = nil)
    grades_with_associations.to_a
  end

  # Check if a student has sufficient grades in a class
  def has_sufficient_grades?(school_class_id)
    # Get all grades for the class
    class_grades = grades.joins(examination: { course: :school_class })
                        .where(courses: { school_class_id: school_class_id })

    # Check if there are any grades
    return false if class_grades.empty?

    # Calculate average grade
    average_grade = class_grades.average(:value).to_f

    # Consider grades sufficient if average is at least 4.0
    average_grade >= 4.0
  end
end
