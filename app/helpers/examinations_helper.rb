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
    can_manage_examinations?(course)
  end
  
  # Check if the current user can edit an examination
  def can_edit_examination?(examination)
    can_manage_examinations?(examination.course)
  end
  
  # Check if the current user can delete an examination
  def can_delete_examination?(examination)
    can_manage_examinations?(examination.course)
  end
  
  # Check if the current user can manage grades for an examination
  def can_manage_grades?(examination)
    can_manage_examinations?(examination.course)
  end
  
  # Check if the current user can manage examinations for a course or school class
  def can_manage_examinations?(record)
    return false unless person_signed_in?
    
    # Deans can manage examinations for all courses
    return true if current_person.dean?
    
    # Teachers can manage examinations for courses they teach
    if current_person.teacher?
      # If record is a Course, check if teacher teaches it
      if record.is_a?(Course)
        return record.teacher_id == current_person.id
      end
      
      # If record is a SchoolClass, check if teacher is class master
      if record.is_a?(SchoolClass)
        return record.master_id == current_person.id
      end
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
