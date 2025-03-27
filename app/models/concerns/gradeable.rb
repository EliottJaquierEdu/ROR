module Gradeable
  extend ActiveSupport::Concern

  included do
    has_many :grades, foreign_key: "person_id", dependent: :destroy, class_name: "Grade"
  end

  def grades_with_associations
    grades.includes(examination: { course: [:subject, :term] })
  end

  def grades_by_term(school_class_id = nil)
    grades_hash = {}

    filtered_grades = grades_with_associations
    if school_class_id.present?
      filtered_grades = filtered_grades.joins(examination: { course: :school_class })
                                     .where(courses: { school_class_id: school_class_id })
    end

    filtered_grades.each do |grade|
      term = grade.examination&.course&.term
      next unless term
      grades_hash[term.name] ||= []
      grades_hash[term.name] << grade
    end

    grades_hash
  end

  def grades_by_term_and_subject(school_class_id = nil)
    result = {}

    grades_by_term(school_class_id).each do |term_name, term_grades|
      result[term_name] = {}

      term_grades.each do |grade|
        subject = grade.examination&.course&.subject
        next unless subject

        result[term_name][subject] ||= []
        result[term_name][subject] << grade
      end
    end

    result
  end

  def term_average(term_name, school_class_id = nil)
    term_grades = grades_by_term(school_class_id)[term_name]
    return 0 if term_grades.nil? || term_grades.empty?

    term_grades.sum { |g| g.value } / term_grades.size
  end

  def subject_average(term_name, subject, school_class_id = nil)
    term_subject_data = grades_by_term_and_subject(school_class_id)[term_name]
    return 0 if term_subject_data.nil?

    subject_grades = term_subject_data[subject]
    return 0 if subject_grades.nil? || subject_grades.empty?

    subject_grades.sum { |g| g.value } / subject_grades.size
  end

  def sorted_terms(school_class_id = nil)
    grades_by_term(school_class_id).keys.sort
  end

  def overall_average(school_class_id = nil)
    filtered_grades = grades
    if school_class_id.present?
      filtered_grades = filtered_grades.joins(examination: { course: :school_class })
                                     .where(courses: { school_class_id: school_class_id })
    end
    return 0 if filtered_grades.empty?
    filtered_grades.average(:value).to_f
  end
end
