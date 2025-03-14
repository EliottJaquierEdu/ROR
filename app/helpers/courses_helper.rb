module CoursesHelper
  # Check if the current user can view courses
  def can_view_courses?
    # All authenticated users can view courses
    person_signed_in?
  end
  
  # Check if the current user can view a specific course
  def can_view_course?(course)
    return false unless person_signed_in?
    
    # Deans can view all courses
    return true if current_person.dean?
    
    # Teachers can view all courses
    return true if current_person.teacher?
    
    # Students can only view courses for their school class
    if current_person.student?
      return current_person.school_classes.include?(course.school_class)
    end
    
    false
  end
  
  # Check if the current user can create courses
  def can_create_course?
    return false unless person_signed_in?
    
    # Only deans can create courses
    current_person.dean?
  end
  
  # Check if the current user can edit a course
  def can_edit_course?(course)
    return false unless person_signed_in?
    
    # Only deans can edit courses
    current_person.dean?
  end
  
  # Check if the current user can delete a course
  def can_delete_course?(course)
    return false unless person_signed_in?
    
    # Only deans can delete courses
    current_person.dean?
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
  
  # Get the list of courses the current user can see
  def visible_courses
    return [] unless person_signed_in?
    
    # Deans and teachers can see all courses
    return Course.all if current_person.dean? || current_person.teacher?
    
    # Students can only see courses for their school classes
    if current_person.student?
      return Course.joins(:school_class)
                  .where(school_class: current_person.school_classes)
    end
    
    []
  end
end
