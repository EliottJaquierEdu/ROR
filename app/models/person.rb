class Person < ApplicationRecord
  include WeeklySchedulable
  include Archivable

  # NOTE: This model includes an implementation of the empty? method
  # to fix an issue with Devise authentication. Without this method,
  # authentication fails with "undefined method 'empty?' for #<Student>"
  # when trying to sign in. This is related to how Rack/Devise processes
  # authentication and checks if objects are empty.

  # Include default devise modules
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable,
         :validatable

  # Scopes
  scope :teachers, -> { where(type: ['Teacher', 'Dean']) }

  has_one :address
  accepts_nested_attributes_for :address

  has_and_belongs_to_many :school_classes, join_table: "people_school_classes"

  # Teacher-class relationships
  has_many :mastered_classes, class_name: 'SchoolClass', foreign_key: 'master_id'
  has_many :courses, foreign_key: 'teacher_id'
  has_many :taught_classes, through: :courses, source: :school_class

  belongs_to :student_status, optional: true
  belongs_to :teacher_status, optional: true

  validates :student_status, presence: true, if: :student?
  validates :teacher_status, presence: true, if: :teacher?

  has_many :grades, foreign_key: "person_id", dependent: :destroy, class_name: "Grade"

  # Define a method to get all school classes based on role
  def school_classes
    if teacher?
      SchoolClass.where(id: SchoolClass.select(:id)
        .left_joins(:courses)
        .where('school_classes.master_id = :person_id OR courses.teacher_id = :person_id', person_id: id)
        .distinct)
    else
      super  # Use the default has_and_belongs_to_many association
    end
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def student?
    type == "Student"
  end

  def teacher?
    type == "Teacher" || type == "Dean"
  end

  def dean?
    type == "Dean"
  end

  def can_view_grade?(grade)
    return true if dean? || teacher?
    return false unless student?
    grade.person_id == id
  end

  def can_manage_resources?
    dean?
  end

  # Define empty? method to return false for Person objects
  # This prevents the NoMethodError in People::SessionsController#create
  # Devise/Rack uses this method during authentication to check if the user object is empty
  # Without this method, authentication fails with "undefined method 'empty?' for #<Student>"
  def empty?
    false
  end

  # Ensure the model responds to empty? method
  # This is needed because some parts of Rails/Rack may check respond_to?(:empty?)
  # before actually calling the method, especially during authentication
  def respond_to?(method_name, include_private = false)
    method_name.to_sym == :empty? || super
  end

  # String representation of a Person
  def to_s
    full_name
  end

  # JSON representation of a Person
  def as_json(options = {})
    super(options.merge(
      methods: [:full_name, :type],
      except: [:encrypted_password, :reset_password_token, :reset_password_sent_at]
    ))
  end

  # Get all grades with their associated data for efficient report generation
  def grades_with_associations
    grades.includes(examination: { course: :subject })
  end

  # Get student's grades organized by term
  def grades_by_term(school_class_id = nil)
    # This method returns a hash of grades grouped by term
    grades_hash = {}

    filtered_grades = applicable_grades
    if school_class_id.present?
      filtered_grades = filtered_grades.joins(examination: { course: :school_class })
                                     .where(courses: { school_class_id: school_class_id })
    end

    filtered_grades.each do |grade|
      term = grade.examination&.course&.term
      next unless term
      grades_hash[term] ||= []
      grades_hash[term] << grade
    end

    grades_hash
  end

  # Get student's grades organized by term and subject
  def grades_by_term_and_subject(school_class_id = nil)
    result = {}

    grades_by_term(school_class_id).each do |term, term_grades|
      result[term] = {}

      # Group by subject
      term_grades.each do |grade|
        subject = grade.examination&.course&.subject
        next unless subject

        result[term][subject] ||= []
        result[term][subject] << grade
      end
    end

    result
  end

  # Calculate average grade for a specific term
  def term_average(term, school_class_id = nil)
    term_grades = grades_by_term(school_class_id)[term]
    return 0 if term_grades.nil? || term_grades.empty?

    term_grades.sum { |g| g.value } / term_grades.size
  end

  # Calculate average grade for a specific subject in a term
  def subject_average(term, subject, school_class_id = nil)
    term_subject_data = grades_by_term_and_subject(school_class_id)[term]
    return 0 if term_subject_data.nil?

    subject_grades = term_subject_data[subject]
    return 0 if subject_grades.nil? || subject_grades.empty?

    subject_grades.sum { |g| g.value } / subject_grades.size
  end

  # Get a list of terms sorted chronologically
  def sorted_terms(school_class_id = nil)
    grades_by_term(school_class_id).keys.sort
  end

  # Calculate overall average across all grades or for a specific class
  def overall_average(school_class_id = nil)
    filtered_grades = applicable_grades
    if school_class_id.present?
      filtered_grades = filtered_grades.joins(examination: { course: :school_class })
                                     .where(courses: { school_class_id: school_class_id })
    end
    return 0 if filtered_grades.empty?
    filtered_grades.average(:value).to_f
  end

  # Show page data loading methods
  def load_show_data(selected_week = nil)
    if student?
      load_student_data
    elsif teacher?
      load_teacher_data(selected_week)
    end
  end

  private

  def load_student_data
    grades_with_associations.to_a
  end

  def load_teacher_data(selected_week = nil)
    week_range = selected_week_range(selected_week)

    {
      school_classes: load_teacher_classes,
      week_courses: load_teacher_week_courses(week_range)
    }
  end

  def load_teacher_classes
    school_classes
      .includes(:students, :room, :master, courses: [:subject, :teacher])
      .distinct
  end

  def load_teacher_week_courses(week_range)
    courses
      .includes(:subject, school_class: [:room, :master])
      .where(Arel.sql("CAST(strftime('%w', start_at) AS INTEGER) BETWEEN 1 AND 5"))
      .where("DATE(start_at) BETWEEN ? AND ?", week_range[:start], week_range[:end])
      .order(Arel.sql("CAST(strftime('%w', start_at) AS INTEGER)"), :start_at)
  end

  def archive_dependencies
    # Archive associated records
    address&.archive!
    grades.each(&:archive!)
    mastered_classes.each(&:archive!)

    # For teachers, archive their courses
    courses.each(&:archive!) if type == 'Teacher'

    # Note: We don't automatically archive school_classes as they might still be active
    # even if a student is archived
  end

  def unarchive_dependencies
    # Unarchive associated records
    address&.unarchive!
    # Don't automatically unarchive other associations as they might have been
    # archived for other reasons
  end
end
