module SubjectsHelper
  # Check if the current user can view a specific subject
  def can_view_subject?(subject)
    return false unless person_signed_in?
    return false unless subject
    
    # Deans can view all subjects
    return true if current_person.dean?
    
    # Teachers can view subjects they teach
    if current_person.teacher?
      return subject.courses.exists?(teacher_id: current_person.id)
    end
    
    # Students can view subjects in their classes
    if current_person.student?
      return subject.courses.joins(:school_class).exists?(school_classes: { id: current_person.school_classes.pluck(:id) })
    end
    
    false
  end
  
  # Check if the current user can create subjects
  def can_create_subject?
    return false unless person_signed_in?
    
    # Only deans can create subjects
    current_person.dean?
  end
  
  # Check if the current user can edit a specific subject
  def can_edit_subject?(subject)
    return false unless person_signed_in?
    return false unless subject
    
    # Only deans can edit subjects
    current_person.dean?
  end
  
  # Check if the current user can delete a specific subject
  def can_delete_subject?(subject)
    return false unless person_signed_in?
    return false unless subject
    
    # Only deans can delete subjects
    current_person.dean?
  end
  
  # Get the list of subjects the current user can see
  def visible_subjects
    return [] unless person_signed_in?
    
    # Deans can see all subjects
    return Subject.all if current_person.dean?
    
    # Teachers can see subjects they teach
    if current_person.teacher?
      return Subject.joins(:courses).where(courses: { teacher_id: current_person.id }).distinct
    end
    
    # Students can see subjects in their classes
    if current_person.student?
      return Subject.joins(courses: :school_class)
                   .where(school_classes: { id: current_person.school_classes.pluck(:id) })
                   .distinct
    end
    
    []
  end
end
