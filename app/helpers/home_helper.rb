module HomeHelper
  # Check if the current user can view all students
  def can_view_all_students?
    return false unless person_signed_in?

    # Deans and teachers can view all students
    current_person.dean? || current_person.teacher?
  end

  # Check if the current user can view all teachers
  def can_view_all_teachers?
    return false unless person_signed_in?

    # Deans can view all teachers
    # Teachers can view other teachers
    current_person.dean? || current_person.teacher?
  end

  # Check if the current user can view all school classes
  def can_view_all_school_classes?
    return false unless person_signed_in?

    # Deans can view all school classes
    # Teachers can view all school classes
    # Students can view their own school classes
    current_person.dean? || current_person.teacher? || current_person.student?
  end

  # Check if the current user can view all subjects
  def can_view_all_subjects?
    return false unless person_signed_in?

    # Deans can view all subjects
    # Teachers can view all subjects
    # Students can view subjects related to their courses
    current_person.dean? || current_person.teacher? || current_person.student?
  end

  # Check if the current user can view all examinations
  def can_view_all_examinations?
    return false unless person_signed_in?

    # Deans can view all examinations
    # Teachers can view examinations related to their courses
    # Students can view examinations related to their courses
    current_person.dean? || current_person.teacher? || current_person.student?
  end

  # Get the list of students the current user can see
  def visible_students
    return [] unless person_signed_in?

    # Deans can see all students
    return Student.all if current_person.dean?

    # Teachers can see students in their classes
    if current_person.teacher?
      class_ids = SchoolClass.where(master_id: current_person.id).pluck(:id)
      return Student.joins(:school_classes).where(school_classes: { id: class_ids }).distinct
    end

    # Students can only see themselves
    if current_person.student?
      return Student.where(id: current_person.id)
    end

    []
  end

  # Get the list of teachers the current user can see
  def visible_teachers
    return [] unless person_signed_in?

    # Deans can see all teachers
    return Teacher.includes(courses: [:subject, :school_class, :examinations]) if current_person.dean?

    # Teachers can see all teachers
    return Teacher.includes(courses: [:subject, :school_class, :examinations]) if current_person.teacher?

    # Students can see teachers of their classes
    if current_person.student?
      class_ids = current_person.school_classes.pluck(:id)
      return Teacher.includes(courses: [:subject, :school_class, :examinations])
                   .joins(:school_classes)
                   .where(school_classes: { id: class_ids })
                   .distinct
    end

    []
  end

  # Get the list of school classes the current user can see
  def visible_school_classes
    return [] unless person_signed_in?

    # Deans can see all school classes
    return SchoolClass.all if current_person.dean?

    # Teachers can see all school classes, with emphasis on their own
    return SchoolClass.all if current_person.teacher?

    # Students can only see their own school classes
    if current_person.student?
      return current_person.school_classes
    end

    []
  end

  # Get the list of subjects the current user can see
  def visible_subjects
    return [] unless person_signed_in?

    # Deans can see all subjects
    return Subject.all if current_person.dean?

    # Teachers can see all subjects
    return Subject.all if current_person.teacher?

    # Students can see subjects related to their courses
    if current_person.student?
      class_ids = current_person.school_classes.pluck(:id)
      return Subject.joins(courses: :school_class).where(courses: { school_class_id: class_ids }).distinct
    end

    []
  end

  # Get the list of examinations the current user can see
  def visible_examinations
    return [] unless person_signed_in?

    # Deans can see all examinations
    return Examination.all if current_person.dean?

    # Teachers can see examinations related to their classes
    if current_person.teacher?
      class_ids = SchoolClass.where(master_id: current_person.id).pluck(:id)
      return Examination.joins(course: :school_class).where(course: { school_class_id: class_ids })
    end

    # Students can see examinations related to their classes
    if current_person.student?
      class_ids = current_person.school_classes.pluck(:id)
      return Examination.joins(course: :school_class).where(course: { school_class_id: class_ids })
    end

    []
  end
end
