class Course < ApplicationRecord
  belongs_to :school_class
  belongs_to :subject
  has_many :examinations

  validates :term, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :week_day, presence: true, inclusion: { in: 0..6 } # Ensures it's a valid weekday
  
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
end
