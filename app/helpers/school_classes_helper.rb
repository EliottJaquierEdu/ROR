module SchoolClassesHelper
  # Check if the current user can view a specific school class
  def can_view_school_class?(school_class)
    current_person.dean? ||
    current_person.teacher? ||
    current_person.student? && current_person.school_classes.include?(school_class)
  end

  # Check if the current user can create school classes
  def can_create_school_class?
    current_person.dean?
  end

  # Check if the current user can edit a specific school class
  def can_edit_school_class?(school_class)
    current_person.dean?
  end

  # Check if the current user can delete a specific school class
  def can_delete_school_class?(school_class)
    return false unless person_signed_in?
    return false unless school_class

    # Only deans can delete classes
    current_person.dean?
  end

  # Get the list of school classes the current user can see
  def visible_school_classes
    if current_person.dean?
      SchoolClass.all.includes(:master, :room, :students)
    elsif current_person.teacher?
      SchoolClass.joins(:courses).where(courses: { teacher_id: current_person.id }).distinct
    else
      current_person.school_classes
    end
  end

  # Check if the current user can manage students in a class
  def can_manage_students?(school_class)
    return false unless person_signed_in?
    return false unless school_class

    # Deans can manage students in all classes
    return true if current_person.dean?

    # Teachers can manage students in classes they teach
    if current_person.teacher?
      return school_class.master_id == current_person.id
    end

    false
  end

  # Check if the current user can manage examinations in a class
  def can_manage_examinations?(record)
    return false unless person_signed_in?

    # Deans can manage examinations in all classes
    return true if current_person.dean?

    # Teachers can manage examinations in classes they teach
    if current_person.teacher?
      # Handle both Course and SchoolClass objects
      school_class = record.is_a?(Course) ? record.school_class : record
      return school_class.master_id == current_person.id
    end

    false
  end

  def can_archive_school_class?(school_class)
    current_person.dean?
  end

  def can_unarchive_school_class?(school_class)
    current_person.dean?
  end
end
