class Course < ApplicationRecord
  include Archivable

  belongs_to :school_class
  belongs_to :subject
  belongs_to :teacher, class_name: 'Person'
  belongs_to :term
  has_many :examinations, dependent: :destroy

  validates :start_at, presence: true
  validates :end_at, presence: true

  # Scopes for filtering
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) if subject_id.present? }
  scope :by_school_class, ->(school_class_id) { where(school_class_id: school_class_id) if school_class_id.present? }
  scope :by_term, ->(term_id) { where(term_id: term_id) if term_id.present? }
  scope :by_teacher, ->(teacher_id) { where(teacher_id: teacher_id) if teacher_id.present? }
  
  # Scopes for sorting
  scope :order_by_subject, ->(direction = :asc) { 
    joins(:subject).order("subjects.name #{direction}") 
  }
  
  scope :order_by_term, ->(direction = :asc) { 
    joins(:term).order("terms.name #{direction}") 
  }
  
  scope :order_by_school_class, ->(direction = :asc) { 
    joins(:school_class).order("school_classes.name #{direction}") 
  }
  
  scope :order_by_teacher, ->(direction = :asc) { 
    joins(:teacher).order("people.lastname #{direction}, people.firstname #{direction}") 
  }

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
