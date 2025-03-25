module Teachable
  extend ActiveSupport::Concern

  included do
    has_many :mastered_classes, class_name: 'SchoolClass', foreign_key: 'master_id'
    has_many :courses, foreign_key: 'teacher_id'
    has_many :taught_classes, through: :courses, source: :school_class
    has_many :subjects, -> { distinct }, through: :courses
  end

  def school_classes
    SchoolClass.where(id: SchoolClass.select(:id)
      .left_joins(:courses)
      .where('school_classes.master_id = :person_id OR courses.teacher_id = :person_id', person_id: id)
      .distinct)
  end

  def load_teacher_classes
    school_classes
      .includes(:students, :room, :master, courses: [:subject, :teacher])
      .distinct
  end

  def load_teacher_week_courses(week_range)
    courses
      .includes(:subject, school_class: [:room, :master])
      .where(week_day: 1..5)
      .where("DATE(start_at) BETWEEN ? AND ?", week_range[:start], week_range[:end])
      .order(:week_day, :start_at)
  end

  def load_show_data(selected_week = nil)
    week_range = selected_week_range(selected_week)
    {
      school_classes: load_teacher_classes,
      week_courses: load_teacher_week_courses(week_range)
    }
  end
end
