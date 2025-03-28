class SchoolClass < ApplicationRecord
  include WeeklyCourseable
  include Archivable

  belongs_to :room
  belongs_to :master, class_name: "Person", optional: true
  has_and_belongs_to_many :students, class_name: "Person", join_table: "people_school_classes"

  has_many :course_school_classes
  has_many :courses, through: :course_school_classes
  has_many :examinations, through: :courses

  validates :name, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
  validates :room_id, presence: true

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

  private

  def archive_dependencies
    courses.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive courses as they might have been archived for other reasons
  end
end
