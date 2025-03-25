class SchoolClass < ApplicationRecord
  belongs_to :room
  belongs_to :master, class_name: "Person"
  has_and_belongs_to_many :students, class_name: "Person", join_table: "people_school_classes"

  has_many :courses
  has_many :examinations, through: :courses

  # String representation of a SchoolClass
  def to_s
    "#{name} (#{year})"
  end

  # JSON representation of a SchoolClass
  def as_json(options = {})
    super(options.merge(
      include: {
        room: { only: [:id, :name] },
        master: { only: [:id, :firstname, :lastname], methods: [:full_name] }
      },
      methods: [:student_count]
    ))
  end

  # Helper method to get the number of students
  def student_count
    students.count
  end
end
