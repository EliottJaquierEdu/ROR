class Course < ApplicationRecord
  include Archivable

  belongs_to :school_class
  belongs_to :subject
  belongs_to :teacher, class_name: 'Person'
  has_many :examinations, dependent: :destroy

  validates :term, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :week_day, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 7 }

  # String representation of a Course
  def to_s
    "#{subject&.name} - #{term} (#{school_class&.name})"
  end

  # JSON representation of a Course
  def as_json(options = {})
    super(options.merge(
      include: {
        subject: { only: [:id, :name] },
        school_class: { only: [:id, :name, :year] }
      },
      methods: [:weekday_name]
    ))
  end

  # Helper method to get the weekday name
  def weekday_name
    Date::DAYNAMES[week_day]
  end

  private

  def archive_dependencies
    examinations.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive examinations as they might have been archived for other reasons
  end
end
