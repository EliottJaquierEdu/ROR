class Subject < ApplicationRecord
  include WeeklyCourseable

  has_many :courses, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # String representation of a Subject
  def to_s
    name
  end

  # JSON representation of a Subject
  def as_json(options = {})
    super(options.merge(
      methods: [:course_count]
    ))
  end

  # Helper method to get the number of courses
  def course_count
    courses.count
  end
end
