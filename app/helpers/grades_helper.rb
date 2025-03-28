module GradesHelper
  # Check if the current user can view grades
  def can_view_grades?
    # All authenticated users can view grades
    person_signed_in?
  end

  # Check if the current user can view a specific grade
  def can_view_grade?(grade)
    return false unless person_signed_in?

    # Use the can_view_grade? method from the Person model if it exists
    return current_person.can_view_grade?(grade) if current_person.respond_to?(:can_view_grade?)

    # Deans can view all grades
    return true if current_person.dean?

    # Teachers can view all grades
    return true if current_person.teacher?

    # Students can only view their own grades
    if current_person.student?
      return grade.person_id == current_person.id
    end

    false
  end

  # Check if the current user can create grades
  def can_create_grade?
    return false unless person_signed_in?

    # Only deans and teachers can create grades
    current_person.dean? || current_person.teacher?
  end

  # Check if the current user can create a grade for a specific examination
  def can_create_grade_for_examination?(examination)
    return false unless person_signed_in?

    # Deans can create grades for any examination
    return true if current_person.dean?

    # Teachers can only create grades for examinations in subjects they teach
    if current_person.teacher?
      # Get the subject of the examination through its course
      subject = examination.course&.subject
      return false unless subject

      # Check if the teacher teaches this subject
      return current_person.courses.exists?(subject: subject)
    end

    # Students cannot create grades
    false
  end

  # Check if the current user can edit a grade
  def can_edit_grade?(grade)
    return false unless person_signed_in?

    # Deans can edit all grades
    return true if current_person.dean?

    # Teachers can only edit grades for examinations in subjects they teach
    if current_person.teacher?
      # Get the subject of the grade through its examination and course
      subject = grade.examination&.course&.subject
      return false unless subject

      # Check if the teacher teaches this subject
      return current_person.courses.exists?(subject: subject)
    end

    # Students cannot edit grades
    false
  end

  # Check if the current user can delete a grade
  def can_delete_grade?(grade)
    return false unless person_signed_in?

    # Deans can delete all grades
    return true if current_person.dean?

    # Teachers can only delete grades for examinations in subjects they teach
    if current_person.teacher?
      # Get the subject of the grade through its examination and course
      subject = grade.examination&.course&.subject
      return false unless subject

      # Check if the teacher teaches this subject
      return current_person.courses.exists?(subject: subject)
    end

    # Students cannot delete grades
    false
  end

  # Get the list of grades the current user can see
  def visible_grades
    return [] unless person_signed_in?

    # Deans can see all grades
    return Grade.includes(student: :student_status, examination: { course: :subject }) if current_person.dean?

    # Teachers can see all grades
    return Grade.includes(student: :student_status, examination: { course: :subject }) if current_person.teacher?

    # Students can only see their own grades
    if current_person.student?
      return Grade.includes(student: :student_status, examination: { course: :subject })
                 .where(person_id: current_person.id)
    end

    []
  end

  # Organize grades by term (semester)
  def organize_grades_by_term(grades)
    grades_by_term = {}

    grades.each do |grade|
      term = grade.examination&.course&.term
      next unless term
      grades_by_term[term] ||= []
      grades_by_term[term] << grade
    end

    # Sort terms chronologically (assuming term format can be sorted)
    sorted_terms = grades_by_term.keys.sort

    [sorted_terms, grades_by_term]
  end

  # Group grades by subject for a specific term
  def group_term_grades_by_subject(term_grades)
    grades_by_subject = {}

    term_grades.each do |grade|
      subject = grade.examination&.course&.subject
      next unless subject
      grades_by_subject[subject] ||= []
      grades_by_subject[subject] << grade
    end

    grades_by_subject
  end

  # Calculate the average grade for an array of grades
  def calculate_average_grade(grades)
    return 0 if grades.empty?
    (grades.sum { |g| g.value } / grades.size).to_f
  end

  # Format a grade value with proper decimal places
  def format_grade(grade_value)
    sprintf('%.2f', grade_value)
  end

  # Determine if a grade is passing (success) or failing (danger)
  def grade_status_class(grade_value)
    grade_value >= 4.0 ? 'bg-success' : 'bg-danger'
  end
end
