module ExaminationsHelper
  # Check if the current user can view examinations
  def can_view_examinations?
    # All authenticated users can view examinations
    person_signed_in?
  end
  
  # Check if the current user can view a specific examination
  def can_view_examination?(examination)
    return false unless person_signed_in?
    
    # Deans can view all examinations
    return true if current_person.dean?
    
    # Teachers can view all examinations
    return true if current_person.teacher?
    
    # Students can only view examinations for their school classes
    if current_person.student?
      return current_person.school_classes.include?(examination.course&.school_class)
    end
    
    false
  end
  
  # Check if the current user can create examinations
  def can_create_examination?
    return false unless person_signed_in?
    
    # Deans can create examinations
    return true if current_person.dean?
    
    # Teachers can create examinations
    return true if current_person.teacher?
    
    # Students cannot create examinations
    false
  end
  
  # Check if the current user can create an examination for a specific course
  def can_create_examination_for_course?(course)
    return false unless person_signed_in?
    
    # Deans can create examinations for any course
    return true if current_person.dean?
    
    # Teachers who are class masters can create examinations for their classes
    if current_person.teacher?
      return course.school_class&.master_id == current_person.id
    end
    
    # Students cannot create examinations
    false
  end
  
  # Check if the current user can edit an examination
  def can_edit_examination?(examination)
    return false unless person_signed_in?
    
    # Deans can edit all examinations
    return true if current_person.dean?
    
    # Teachers who are class masters can edit examinations for their classes
    if current_person.teacher?
      return examination.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot edit examinations
    false
  end
  
  # Check if the current user can delete an examination
  def can_delete_examination?(examination)
    return false unless person_signed_in?
    
    # Deans can delete all examinations
    return true if current_person.dean?
    
    # Teachers who are class masters can delete examinations for their classes
    if current_person.teacher?
      return examination.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot delete examinations
    false
  end
  
  # Check if the current user can manage grades for an examination
  def can_manage_grades?(examination)
    return false unless person_signed_in?
    
    # Deans can manage grades for all examinations
    return true if current_person.dean?
    
    # Teachers who are class masters can manage grades for their classes
    if current_person.teacher?
      return examination.course&.school_class&.master_id == current_person.id
    end
    
    # Students cannot manage grades
    false
  end
  
  # Check if the current user can manage examinations for a course
  def can_manage_examinations?(course)
    return false unless person_signed_in?
    
    # Deans can manage examinations for all courses
    return true if current_person.dean?
    
    # Teachers who are class masters can manage examinations for their classes
    if current_person.teacher?
      return course.school_class&.master_id == current_person.id
    end
    
    false
  end
  
  # Get the list of examinations the current user can see
  def visible_examinations
    return [] unless person_signed_in?
    
    # Deans and teachers can see all examinations
    return Examination.all if current_person.dean? || current_person.teacher?
    
    # Students can only see examinations for their school classes
    if current_person.student?
      return Examination.joins(course: :school_class)
                       .where(course: { school_class: current_person.school_classes })
    end
    
    []
  end
end
