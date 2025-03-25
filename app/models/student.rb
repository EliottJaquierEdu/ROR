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
end
