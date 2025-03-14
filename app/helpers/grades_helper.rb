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
    
    # Teachers who are class masters can create grades for their classes
    if current_person.teacher?
      return examination.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot create grades
    false
  end
  
  # Check if the current user can edit a grade
  def can_edit_grade?(grade)
    return false unless person_signed_in?
    
    # Deans can edit all grades
    return true if current_person.dean?
    
    # Teachers who are class masters can edit grades for their classes
    if current_person.teacher?
      return grade.examination&.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot edit grades
    false
  end
  
  # Check if the current user can delete a grade
  def can_delete_grade?(grade)
    return false unless person_signed_in?
    
    # Deans can delete all grades
    return true if current_person.dean?
    
    # Teachers who are class masters can delete grades for their classes
    if current_person.teacher?
      return grade.examination&.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot delete grades
    false
  end
  
  # Get the list of grades the current user can see
  def visible_grades
    return [] unless person_signed_in?
    
    # Deans can see all grades
    return Grade.all if current_person.dean?
    
    # Teachers can see all grades
    return Grade.all if current_person.teacher?
    
    # Students can only see their own grades
    if current_person.student?
      return Grade.where(person_id: current_person.id)
    end
    
    []
  end
end
