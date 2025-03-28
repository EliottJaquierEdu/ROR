class Course < ApplicationRecord
  include Archivable

  belongs_to :school_class
  belongs_to :subject
  belongs_to :teacher, class_name: 'Person'
  belongs_to :term
  has_many :examinations, dependent: :destroy

  validates :start_at, presence: true
  validates :end_at, presence: true

  # String representation of a Course
  def to_s
    "#{subject&.name} - #{term&.name} (#{school_class&.name})"
  end

  # JSON representation of a Course
  def as_json(options = {})
    super(options.merge(
      include: {
        subject: { only: [:id, :name] },
        school_class: { only: [:id, :name, :year] },
        term: { only: [:id, :name] }
      },
      methods: [:weekday_name]
    ))
  end

  # Helper method to get the weekday name
  def weekday_name
    Date::DAYNAMES[week_day]
  end

  # Compute week_day from start_at
  def week_day
    start_at.wday
  end

  private

  def archive_dependencies
    examinations.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive examinations as they might have been archived for other reasons
  end
end
