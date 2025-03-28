class Subject < ApplicationRecord
  include WeeklyCourseable
  include Archivable

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

  private

  def archive_dependencies
    courses.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive courses as they might have been archived for other reasons
  end
end
